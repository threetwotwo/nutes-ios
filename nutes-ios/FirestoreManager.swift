//
//  FirestoreManager.swift
//  nutes-ios
//
//  Created by Gary on 11/6/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import IGListKit

//Helper class for firebase operations
class FirebaseManager {
	static let shared = FirebaseManager()

	var db: Firestore!

	func configureDB() {
		let settings = db.settings
		settings.areTimestampsInSnapshotsEnabled = true
		db.settings = settings
	}

	func getPostsForUser(username: String, completion: @escaping (_ posts:[ListDiffable]?) -> ()) {
		db.collection("posts").whereField("username", isEqualTo: username).order(by: "timestamp", descending: true).getDocuments { (documents, error) in
			guard error == nil,
				let documents = documents?.documents else {
					print(error?.localizedDescription ?? "Error fetching posts!")
					return
			}
			var items = [ListDiffable]()
			for document in documents {
				let post = Post()
				post.imageURL = document.get("imageURL") as? String
				items.append(post)
			}
			completion(items)
		}
	}

}
