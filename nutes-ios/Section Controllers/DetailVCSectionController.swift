//
//  DetailVCSectionController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class DetailVCSectionController: ListSectionController {
	//MARK: - variables
	var post: Post?

	var likesLabel: UILabel!

	var firestore = FirestoreManager.shared

	//MARK: - Like button pressed
	@objc func likeButtonPressed(_ button: UIButton) {

		let likeCounter = firestore.db.collection("counters").document((post?.id)!)
		let currentUser = firestore.currentUser!

		guard let post = post,
		let likes = post.likes else {return}

		if post.didLike {
			self.post?.likes = likes - 1

			button.setImage(UIImage(named: "heart_bordered"), for: [])
			likesLabel?.attributedText = firestore.constructLikesLabel(totalLikes: post.likes!, followedLikes: post.followedUsernames.count, followedUsernames: post.followedUsernames)
			post.didLike = false
			firestore.decrementCounter(user: currentUser, postID: post.id, ref: likeCounter, numShards: 1) { (success) in
				if !success {
					button.setImage(UIImage(named: "heart_filled"), for: [])

					self.post?.likes = likes + 1

					self.likesLabel?.attributedText =  self.firestore.constructLikesLabel(totalLikes: post.likes!, followedLikes: post.followedUsernames.count, followedUsernames: post.followedUsernames)

					self.post?.didLike = true
				}
			}
		} else {
			button.setImage(UIImage(named: "heart_filled"), for: [])
			self.post?.likes = likes + 1

			post.didLike = true

			self.likesLabel?.attributedText =  self.firestore.constructLikesLabel(totalLikes: post.likes!, followedLikes: post.followedUsernames.count, followedUsernames: post.followedUsernames)

			firestore.incrementCounter(user: currentUser, postID: post.id, ref: likeCounter, numShards: 1) { (success) in
				if !success {
					self.post?.likes = likes - 1

					self.likesLabel?.attributedText =  self.firestore.constructLikesLabel(totalLikes: post.likes!, followedLikes: post.followedUsernames.count, followedUsernames: post.followedUsernames)

					button.setImage(UIImage(named: "heart_bordered"), for: [])
					self.post?.didLike = false
				}
			}
		}
	}

	//MARK: - IGListKit
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

		let cell = context.dequeueReusableCellFromStoryboard(withIdentifier: "NuteBigCell", for: self, at: index) as! PostCell

		self.likesLabel = cell.likesLabel

		cell.usernameLabel.text = post.username

		cell.likesLabel.attributedText = firestore.constructLikesLabel(totalLikes: post.likes!, followedLikes: post.followedUsernames.count, followedUsernames: post.followedUsernames)

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

	override func sizeForItem(at index: Int) -> CGSize {
		guard let frame = collectionContext?.containerSize else { return .zero}
		return CGSize(width: frame.width, height: frame.height/1.5)
	}
}
