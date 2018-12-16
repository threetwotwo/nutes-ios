//
//  UserViewModel.swift
//  nutes-ios
//
//  Created by Gary on 12/15/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class UserViewModel: ListDiffable {

	let username: String
	let timestamp: Date

	init(username: String, timestamp: Date) {
		self.username = username
		self.timestamp = timestamp
	}

	//Since there will only be one UserViewModel in one Post, we can hardcode an identifier
	//This will enforce only a single model and cell being used
	func diffIdentifier() -> NSObjectProtocol {
		return "user" as NSObjectProtocol
	}

	//It is important to write a good equality method for the view model
	//Because anything something changes, forcing the models to not be equal, the cell will be refresed
	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard let object = object as? UserViewModel else {return false}
		return username == object.username
			&& timestamp == object.timestamp
	}
}
