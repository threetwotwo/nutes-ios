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
	static var username: String!
	static var uid: String!
	var identifier: String = UUID().uuidString
	var posts: Int! = 0

}

extension User: ListDiffable {

	func diffIdentifier() -> NSObjectProtocol {
		return identifier as NSString
	}

	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		if self === object { return true }
		return false
	}

}
