//
//  User.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class User {
	var uid: String!
	var username: String!
	var posts: Int! = 0
	var isFollowing = false

	init(uid: String) {
		self.uid = uid
	}

	convenience init(uid: String, username: String) {
		self.init(uid: uid)
		self.username = username	
	}
}

extension User: ListDiffable {

	func diffIdentifier() -> NSObjectProtocol {
		return uid as NSString
	}

	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard self !== object else { return true }
		guard let object = object as? User else { return false }
		return (self.uid) == (object.uid)
	}

}
