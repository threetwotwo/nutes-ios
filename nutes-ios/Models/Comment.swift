//
//  Comment.swift
//  nutes-ios
//
//  Created by Gary on 12/16/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

final class Comment: ListDiffable {
	private var identifier: String = UUID().uuidString

	let commentID: String
	let parentID: String?
	let postID: String
	let username: String
	let text: String
	let timestamp: Date
	let likes: Int

	init(parentID: String?, commentID: String, postID: String, username: String, text: String, likes: Int, timestamp: Date) {
		self.parentID = parentID 
		self.commentID = commentID
		self.postID = postID
		self.username = username
		self.text = text
		self.likes = likes
		self.timestamp = timestamp
	}

	func diffIdentifier() -> NSObjectProtocol {
		return (identifier) as NSObjectProtocol
	}

	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		return true
	}

}
