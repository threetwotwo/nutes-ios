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
	var id = ""
	var username = ""
	var timestamp: Date?
	var image: Data? = nil
	var imageURL: String? = nil
	var likes: Int?
	var didLike = false
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
