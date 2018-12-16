//
//  ActionViewModel.swift
//  nutes-ios
//
//  Created by Gary on 12/15/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class ActionViewModel: ListDiffable {

	let likes: Int
	let followedUsernames: [String]
	let didLike: Bool

	init(likes: Int, followedUsernames: [String], didLike: Bool) {
		self.likes = likes
		self.followedUsernames = followedUsernames
		self.didLike = didLike
	}

	func diffIdentifier() -> NSObjectProtocol {
		return "action" as NSObjectProtocol
	}

	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard let object = object as? ActionViewModel else {return false}
		return likes == object.likes
	}
}
