//
//  CommentSectionController.swift
//  nutes-ios
//
//  Created by Gary on 12/17/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class CommentSectionController: ListBindingSectionController<Comment>,
ListBindingSectionControllerDataSource,
CommentActionCellDelegate {

	var postID: String = ""
	let firestore = FirestoreManager.shared
	var comment: Comment!
	var localLikes: Int? = nil
	var didLike: Bool? = nil

	func didTapHeart(cell: CommentActionCell) {

		self.didLike = !self.didLike!

		let image = self.didLike! ? "heart_filled" : "heart_bordered"

		cell.likeButton.setImage(UIImage(named: image), for: [])

		if didLike! {
			localLikes = (localLikes ?? object?.likes ?? 0) + 1
			firestore.incrementCommentLikesCounter(postID: postID, commentID: comment.commentID)
		} else {
			localLikes = (localLikes ?? object?.likes ?? 0) - 1
			firestore.decrementCommentLikesCounter(postID: postID, commentID: comment.commentID)
		}

		cell.likesLabel.text = "\(localLikes!)"

	}

	func didTapReply(cell: CommentActionCell) {
		guard let vc = viewController as? CommentViewController,
		let commentTextField = vc.commentTextField else {return}
		vc.parentID = comment?.parentID == nil ? comment.commentID : comment.parentID
		let index = vc.collectionView.indexPath(for: cell)?.section
		//Toggle keyboard by hiding keyboard when the same reply button is pressed twice
		if commentTextField.isFirstResponder && vc.replyIndex == index {
			commentTextField.resignFirstResponder()
			vc.replyingToView.isHidden = true
		} else {
			vc.replyIndex = index
			commentTextField.becomeFirstResponder()
			vc.replyingToView.isHidden = false
			let indexPath = vc.collectionView.indexPath(for: cell)
			vc.commentTextField.text = "@\(comment.username) "
			vc.collectionView.scrollToItem(at: indexPath!, at: .bottom, animated: true)
			
		}
		vc.replyingToLabel.text = "Replying to: \(comment.username)"
	}


	override init() {
		super.init()
		dataSource = self
		guard let vc = viewController as? CommentViewController else {return}
		postID = vc.postID
	}
	
	func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
		guard let object = object as? Comment else { fatalError() }
		comment = object
		let results: [ListDiffable] = [
			CommentViewModel(username: object.username, text: object.text, timestamp: object.timestamp),
			ActionViewModel(likes: object.likes, followedUsernames: [], didLike: object.didLike)
		]
		return results
	}

	func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
		let identifier: String

		switch viewModel {
		case is ActionViewModel:
			identifier = comment.parentID == nil ? "commentaction" : "commentreplyaction"
		case is CommentViewModel:
			identifier = comment.parentID == nil ? "commentcomment" : "commentreply"
		default:
			identifier = "null"
		}

		guard let cell = collectionContext?
			.dequeueReusableCellFromStoryboard(withIdentifier: identifier, for: self, at: index)
			else { fatalError() }

		if let cell = cell as? CommentActionCell {
			cell.delegate = self
			self.didLike = (viewModel as! ActionViewModel).didLike
		}
		
		return cell as! UICollectionViewCell & ListBindable
	}

	func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
		guard let width = collectionContext?.containerSize.width else {fatalError()}

		let height: CGFloat

		switch viewModel {
		case is ActionViewModel:
			height = 40
		default:
			let leadingConstraint: CGFloat = comment.parentID == nil ? 0 : 58
			//width of label
			let commentWidth = width - 100 - leadingConstraint
			let commentHeight = textHeight(text: comment.text, width: commentWidth)
			height = commentHeight < 50 ? 50 : commentHeight
		}
		return CGSize(width: width, height: height)
	}

}

func textHeight(text: String?, width: CGFloat) -> CGFloat {
	let font = UIFont.systemFont(ofSize: 15)
	let insets: UIEdgeInsets = UIEdgeInsets(top: 3, left: 11, bottom: 3, right: 11)
	let constrainedSize = CGSize(width: width - insets.left - insets.right, height: .greatestFiniteMagnitude)
	let attributes = [NSAttributedString.Key.font: font]
	let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
	let bounds = text?.boundingRect(with: constrainedSize, options: options, attributes: attributes, context: nil)
	return (bounds?.size.height.rounded(.up))! + insets.top + insets.bottom
}

func requiredHeight(text: String? , width: CGFloat) -> CGFloat {

	let font = UIFont.systemFont(ofSize: 16)
	let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
	label.numberOfLines = 0
	label.font = font
	label.text = text
	label.sizeToFit()
	return max(50,label.frame.height.rounded(.up))
}
