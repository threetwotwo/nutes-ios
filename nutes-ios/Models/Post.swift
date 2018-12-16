//
//  Post.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit
import FirebaseFirestore

class Post {
	private var identifier: String = UUID().uuidString
	let id: String
	let username: String
	let timestamp: Date
	let imageURL: URL
	let likes: Int
	let followedUsernames: [String]
	let didLike: Bool

	init(id: String, username: String, timestamp: Date, imageURL: URL, likes: Int, followedUsernames: [String], didLike: Bool) {
		self.id = id
		self.username = username
		self.timestamp = timestamp
		self.imageURL = imageURL
		self.likes = likes
		self.followedUsernames = followedUsernames
		self.didLike = didLike
	}
}

extension Post: ListDiffable {

	func diffIdentifier() -> NSObjectProtocol {
		return (identifier) as NSString
	}

	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard self !== object else { return true }
		guard let object = object as? Post else { return false }
		return (self.identifier) == (object.identifier)
	}

}
