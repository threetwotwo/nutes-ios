//
//  CommentViewModel.swift
//  nutes-ios
//
//  Created by Gary on 12/18/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class CommentViewModel: ListDiffable {

	let username: String
	let text: String
	let timestamp: Date

	init(username: String, text: String, timestamp: Date) {
		self.username = username
		self.text = text
		self.timestamp = timestamp
	}

	func diffIdentifier() -> NSObjectProtocol {
		return (UUID().uuidString) as NSObjectProtocol
	}

	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		return true
	}
}
