//
//  Post.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class Post {

	var username = ""
	var timestamp = String(NSDate().timeIntervalSince1970)
	var image: Data? = nil
	var imageURL: String? = nil

}

extension Post: ListDiffable {

	func diffIdentifier() -> NSObjectProtocol {
		return (username + timestamp) as NSString
	}

	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard self !== object else { return true }
		guard let object = object as? Post else { return false }
		return (self.username + self.timestamp) == (object.username + object.timestamp)
	}

}
