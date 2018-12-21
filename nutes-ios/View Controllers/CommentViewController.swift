//
//  CommentViewController.swift
//  nutes-ios
//
//  Created by Gary on 12/17/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

class CommentViewController: UIViewController, UITextFieldDelegate {
	//MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var commentTextFieldBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var commentTextField: UITextField!
	@IBOutlet weak var replyingToView: UIView!
	@IBOutlet weak var replyingToLabel: UILabel!

	@IBAction func cancelReplyButton(_ sender: Any) {
		replyingToView.isHidden = true
		parentID = nil
	}

	//MARK: - Variables
	var postID: String!
	var items: [ListDiffable] = []
	var firestore = FirestoreManager.shared
	var parentID: String?

	//MARK: - Adapter
	lazy var adapter: ListAdapter = {
		let updater = ListAdapterUpdater()
		let adapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: 1)
		adapter.collectionView = collectionView
		adapter.dataSource = self
		return adapter
	}()

	//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
		replyingToView.isHidden = true
		self.adapter.performUpdates(animated: true)
		commentTextField.delegate = self
		NotificationCenter.default.addObserver(self,
											   selector: #selector(self.keyboardNotification(notification:)),
											   name: UIResponder.keyboardWillChangeFrameNotification,
											   object: nil)
    }

	//MARK: - Keyboard
	fileprivate func showKeyboard(_ notification: (Notification)) {

		UIView.animate(withDuration: 0.3) {
			guard let userInfo = notification.userInfo,
				let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) else {return}
			let frame = keyboardSize.cgRectValue
			self.commentTextFieldBottomConstraint.constant = frame.height - 64
			self.view.layoutIfNeeded()
		}
	}

	@objc func keyboardNotification(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			let endFrameY = endFrame?.origin.y ?? 0
			let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
			let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
			let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
			let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
			if endFrameY >= UIScreen.main.bounds.size.height {
				self.commentTextFieldBottomConstraint?.constant = 0.0
			} else {
				self.commentTextFieldBottomConstraint?.constant = (endFrame?.size.height) ?? 0.0
			}
			if notification.name == UIResponder.keyboardWillHideNotification {
				collectionView.contentInset = UIEdgeInsets.zero
			} else {
				collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame!.height, right: 0)
			}
			UIView.animate(withDuration: duration,
						   delay: TimeInterval(0),
						   options: animationCurve,
						   animations: { self.view.layoutIfNeeded() },
						   completion: nil)
		}

	}

	//UITextFieldDelegate
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let comment: Comment
		let commentID = "\(postID ?? "")_\(firestore.currentUser.username ?? "")\(Timestamp().seconds)"

		if parentID != nil {
			comment = Comment(parentID: parentID, commentID: commentID, postID: postID, username: firestore.currentUser.username, text: textField.text!, likes: 1, timestamp: Date())
			firestore.createComment(postID: postID, username: firestore.currentUser.username, text: textField.text!, parentID: parentID)
		} else {
			comment = Comment(parentID: nil, commentID: commentID, postID: postID, username: firestore.currentUser.username, text: textField.text!, likes: 1, timestamp: Date())
			firestore.createComment(postID: postID, username: firestore.currentUser.username, text: textField.text!)
		}

		items.append(comment)

		adapter.performUpdates(animated: true, completion: nil)
		self.parentID = nil
		textField.resignFirstResponder()
		replyingToView.isHidden = true
		return true
	}
}

extension CommentViewController: ListAdapterDataSource {
	func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
		return items
	}

	func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
		return CommentSectionController()
	}

	func emptyView(for listAdapter: ListAdapter) -> UIView? {
		return nil
	}

}
