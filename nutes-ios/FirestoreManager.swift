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
class FirestoreManager {
	static let shared = FirestoreManager()

	var db: Firestore!
	var currentUser: User!

	func configureDB() {
		let settings = db.settings
		settings.areTimestampsInSnapshotsEnabled = true
		db.settings = settings
	}

	//MARK: - Listeners
	func addUserListener(uid: String, completion: @escaping (_ data: [String:Any]) -> ()) -> ListenerRegistration {
		let listener: ListenerRegistration!
		listener = db.collection("users").document(uid).addSnapshotListener { (document, error) in
			guard let document = document else {
				print("Document does not exist")
				return
			}
			if let data = document.data() {
				completion(data)
			}
		}
		return listener
	}

	//MARK: - Get a user's info
	func getUserInfo(uid: String, completion: @escaping (_ data: [String:Any]) -> ()) {
		db.collection("users").document(uid).getDocument { (document, error) in
			guard let document = document else {
				print("Document does not exist")
				return
			}
			if let data = document.data() {
				completion(data)
			}
		}
	}

	//MARK: - Observe changes for user
	func observeUser(uid: String, completion: @escaping (_ data: [String:Any]) -> ()) {
		db.collection("users").document(uid).addSnapshotListener { (document, error) in
			guard let document = document else {
				print("Document does not exist")
				return
			}
			if let data = document.data() {
				completion(data)
			}
		}
	}


	//MARK: - Follow/Unfollow
	func followUser(withUID followedID: String, completion: @escaping ()->()) {
		guard let followerID = self.currentUser.uid else {return}
		db.collection("relationships").document("\(followerID)_\(followedID)").setData([
			"followerID" : followerID,
			"followedID" : followedID,
			"timestamp" : FieldValue.serverTimestamp()
		]) { error in
			if let error = error {
				print("Error adding document: \(error)")
			} else {
				print("Document added")
				completion()
			}
		}
	}

	func unfollowUser(withUID followedID: String, completion: @escaping ()->()) {
		guard let followerID = self.currentUser.uid else {return}
		db.collection("relationships").document("\(followerID)_\(followedID)").delete { (error) in
			guard error == nil else {
				print("error deleting document")
				return
			}
			completion()
		}
	}

	//MARK: - Login/Signup
	func createUser(withEmail email: String, fullname:String, username: String, password: String, completion: @escaping () -> ()) {
		Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
			guard error == nil else {
				print(error?.localizedDescription ?? "error in creating user")
				return
			}

			guard let email = authResult?.user.email,
				let uid = Auth.auth().currentUser?.uid else { return }

			self.db.collection("usernames").document(username).setData([
				"uid" : uid,
				"email" : email
			]) {
				error in
				if let error = error {
					print("Error adding document: \(error)")
					Auth.auth().currentUser?.delete()
				} else {
					print("username Document added with ID: \(String(describing: username))")
				}
			}

			self.db.collection("users").document(uid).setData([
				"email" : email,
				"fullname" : fullname,
				"username" : username,
				"timestamp" : FieldValue.serverTimestamp(),
				"posts" : 0,
				"followers" : 0,
				"following" : 0
			]) { error in
				if let error = error {
					print("Error adding document: \(error)")
					Auth.auth().currentUser?.delete()
				} else {
					print("user Document added with ID: \(uid)")
				}
			}
			self.currentUser = User(uid: uid, username: username)
			completion()
		}
	}

	func signIn(forUsername username: String, password: String, completion: @escaping () -> ()) {
		self.db.collection("usernames").document(username).getDocument { (document, error) in
			guard error == nil,
				let document = document,
				let uid = document.get("uid") as? String,
				let email = document.get("email") as? String else {return}

			Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
				guard error == nil else {
					print(error?.localizedDescription ?? "error in logging in")
					return
				}
				self.currentUser = User(uid: uid, username: username)
				completion()
			}
		}
	}

	//MARK: - Retrieve posts
	func getPostsForUser(uid: String, completion: @escaping (_ posts:[ListDiffable]?) -> ()) {
		db.collection("posts").whereField("uid", isEqualTo: uid).order(by: "timestamp", descending: true).getDocuments { (documents, error) in
			guard error == nil,
				let documents = documents?.documents else {
					print(error?.localizedDescription ?? "Error fetching posts!")
					return
			}
			var items = [ListDiffable]()
			for document in documents {
				let post = Post()
				post.username = document.get("username") as! String
				post.timestamp = String((document.get("timestamp") as! Timestamp).seconds)
				post.imageURL = document.get("imageURL") as? String
				items.append(post)
			}
			completion(items)
		}
	}

}

