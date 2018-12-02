//
//  FeedVCSectionController.swift
//  nutes-ios
//
//  Created by Gary on 11/18/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class FeedVCSectionController: ListSectionController {

	var post: Post?

	var likesLabel: UILabel!

	var firestore = FirestoreManager.shared

	var followedLikes = 0

	var followedUsernames = [String]()

	override func didUpdate(to object: Any) {
		guard let post = object as? Post else {return}
		self.post = post
	}

	override func numberOfItems() -> Int {
		return 1
	}

	override func cellForItem(at index: Int) -> UICollectionViewCell {
		guard let context = collectionContext,
			let post = post else {
				return UICollectionViewCell()
		}

		let cell = context.dequeueReusableCellFromStoryboard(withIdentifier: "FeedPostCell", for: self, at: index) as! PostCell

		self.likesLabel = cell.likesLabel

		cell.usernameLabel.text = post.username

		let likeCounter = firestore.db.collection("counters").document(post.id)

		firestore.getTotalLikes(ref: likeCounter) { (totalLikes) in
			post.likes = totalLikes
			self.firestore.getFollowedLikes(postID: post.id, limit: 1, completion: { (followedLikes, usernames) in

				self.followedLikes = followedLikes
				self.followedUsernames = usernames

				cell.likesLabel.attributedText =	 self.firestore.constructLikesLabel(totalLikes: totalLikes, followedLikes: followedLikes, followedUsernames: usernames)
			})
		}

		if let imageURL = URL(string: post.imageURL!) {
			cell.imageView.sd_setImage(with: imageURL)
		}

		firestore.userDidLikePost(username: firestore.currentUser.username, postID: post.id) { (didLike) in
			let imageName = didLike ? "heart_filled" : "heart_bordered"
			cell.favoriteButton.setImage(UIImage(named: imageName), for: [])
			cell.favoriteButton.isEnabled = true
			post.didLike = didLike
		}
		//Since cannot add IBAction, use addTarget instead
		cell.favoriteButton.addTarget(self, action: #selector(likeButtonPressed(_:)), for: .touchUpInside)

		cell.favoriteButton.tag = index

		return cell
	}

	@objc func likeButtonPressed(_ button: UIButton) {

		let likeCounter = firestore.db.collection("counters").document((post?.id)!)
		let currentUser = firestore.currentUser!

		if (post?.didLike)! {
			button.setImage(UIImage(named: "heart_bordered"), for: [])
			post?.likes = (post?.likes)! - 1
			likesLabel?.attributedText = firestore.constructLikesLabel(totalLikes: (post?.likes)!, followedLikes: self.followedLikes, followedUsernames: self.followedUsernames)
			post?.didLike = false
			firestore.decrementCounter(user: currentUser, postID: post!.id, ref: likeCounter, numShards: 1) { (success) in
				if !success {
					button.setImage(UIImage(named: "heart_filled"), for: [])

					self.post?.likes = (self.post?.likes)! + 1

					self.likesLabel?.attributedText =  self.firestore.constructLikesLabel(totalLikes: (self.post?.likes)!, followedLikes: self.followedLikes, followedUsernames: self.followedUsernames)

					self.post?.didLike = true
				}
			}
		} else {
			button.setImage(UIImage(named: "heart_filled"), for: [])
			post?.likes = (post?.likes)! + 1

			post?.didLike = true

			self.likesLabel?.attributedText =  self.firestore.constructLikesLabel(totalLikes: (self.post?.likes)!, followedLikes: self.followedLikes, followedUsernames: self.followedUsernames)

			firestore.incrementCounter(user: currentUser, postID: post!.id, ref: likeCounter, numShards: 1) { (success) in
				if !success {
					self.post?.likes = (self.post?.likes)! - 1

					self.likesLabel?.attributedText =  self.firestore.constructLikesLabel(totalLikes: (self.post?.likes)!, followedLikes: self.followedLikes, followedUsernames: self.followedUsernames)
					
					button.setImage(UIImage(named: "heart_bordered"), for: [])
					self.post?.didLike = false
				}
			}
		}
	}

	override func sizeForItem(at index: Int) -> CGSize {
		guard let frame = collectionContext?.containerSize else { return .zero}
		return CGSize(width: frame.width, height: frame.height/1.5)
	}

	override func didSelectItem(at index: Int) {
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
		vc.post = post
		viewController?.navigationController?.pushViewController(vc, animated: true)
	}
}
