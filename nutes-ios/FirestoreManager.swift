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
	let defaults = UserDefaults.standard

	func configureDB() {
		let settings = db.settings
		settings.areTimestampsInSnapshotsEnabled = true
		db.settings = settings
	}

	//MARK: - Counter
	func createCounter(ref: DocumentReference, numShards: Int) {
		ref.setData(["numShards": numShards]){ (err) in
			for i in 0..<numShards {
				ref.collection("shards").document(String(i)).setData(["count": 0])
			}
		}
	}

	//check if user liked post
	func userDidLikePost(username: String, postID: String, completion: @escaping (Bool)->()) {
		let userRef = db.collection("likes")
			.whereField("postID", isEqualTo: postID)
			.whereField("username", isEqualTo: username)
		userRef.getDocuments { (documents, error) in
			guard error == nil,
				let documents = documents else {
				print(error?.localizedDescription ?? "error checking like")
				return
			}
			let didLike = !documents.isEmpty 
			completion(didLike)
		}
	}

	func incrementCounter(user:User, postID: String, numShards: Int, completion: @escaping (Bool)->()) {
		// Select a shard of the counter at random
		let ref = db.collection("counters").document(postID)
		let shardId = Int(arc4random_uniform(UInt32(numShards)))
		let shardRef = ref.collection("shards").document(String(shardId))

		guard let username = user.username,
			let uid = user.uid else {return}
		let likeRef = db.collection("likes").document("\(postID)_\(username)")

		// Update count in a transaction
		db.runTransaction({ (transaction, errorPointer) -> Any? in
			do {

				let shardData = try transaction.getDocument(shardRef).data() ?? [:]
				let shardCount = shardData["count"] as! Int
				transaction.updateData([
					"count": shardCount + 1
					], forDocument: shardRef)

				let username = user.username!
				let timestamp = FieldValue.serverTimestamp()

				transaction.setData([
					"postID" : postID,
					"uid" : uid,
					"username"	: username,
					"timestamp" : timestamp
					], forDocument: likeRef)

			} catch {
				// Error getting shard data
				// ...
				print(error.localizedDescription)
			}
			return nil
		}) { (object, error) in
			// ...
			if error != nil {
				print("increased \(0)")
				completion(false)

			} else {
				print("increased \(1)")
				completion(true)
			}
		}
	}

	func decrementCounter(user: User, postID: String, numShards: Int, completion: @escaping (Bool)->()) {
		// Select a shard of the counter at random
		let ref = db.collection("counters").document(postID)
		let shardId = Int(arc4random_uniform(UInt32(numShards)))
		let shardRef = ref.collection("shards").document(String(shardId))

		guard let username = user.username else {return}

		let likeRef = db.collection("likes").document("\(postID)_\(username)")

		// Update count in a transaction
		db.runTransaction({ (transaction, errorPointer) -> Any? in
			do {
				let shardData = try transaction.getDocument(shardRef).data() ?? [:]
				let shardCount = shardData["count"] as! Int
				transaction.updateData(["count": shardCount - 1], forDocument: shardRef)
				transaction.deleteDocument(likeRef)
			} catch {
				// Error getting shard data
				// ...
			}

			return nil
		}) { (object, error) in
			// ...
			if error != nil {
				print("decreased \(0)")
				completion(false)

			} else {
				print("decreased \(1)")
				completion(true)
			}
		}
	}

	func incrementCommentLikeCounter(username: String, postID: String, commentID: String) {

		let counterID = "\(postID)_\(commentID)"
		let ref = db.collection("counters").document(counterID)

		let shardId = Int(arc4random_uniform(UInt32(10)))
		let shardRef = ref.collection("shards").document(String(shardId))

		let likeID = "\(counterID)_\(username)"
		let likeRef = db.collection("likes").document(likeID)

		db.runTransaction({ (transaction, errorPointer) -> Any? in
			do {
				let shardData = try transaction.getDocument(shardRef).data() ?? [:]
				let shardCount = shardData["count"] as! Int
				transaction.updateData(["count": shardCount - 1], forDocument: shardRef)

				let timestamp = FieldValue.serverTimestamp()

				transaction.setData([
					"postID" : postID,
					"commentID" : commentID,
					"username"	: username,
					"timestamp" : timestamp
					], forDocument: likeRef)
			}  catch let error as NSError {
				errorPointer?.pointee = error
			}
			return nil
		}) { (object, error) in
			// ...
			if error != nil {
				print(error?.localizedDescription)
			}
		}
	}

	func getTotalLikes(ref: DocumentReference, completion: @escaping (Int) -> ()) {
		ref.collection("shards").getDocuments() { (querySnapshot, err) in
			var totalCount = 0
			var uids = [String]()
			if err != nil {
				// Error getting shards
				// ...
			} else {
				for document in querySnapshot!.documents {
					if let count = document.data()["count"] as? Int{
						totalCount += count
					}

					if let uid = document.data()["users"] as? [String] {
						uids.append(contentsOf: uid)
					}
				}
				print("uids \(uids)")
			}

			completion(totalCount)
		}
	}

	func getFollowedLikes(postID: String, limit: Int, completion: @escaping (Int, [String]) -> ()) {
		getFollowedUsers(for: currentUser.username) { (documents) in

			var usernames = [String]()
			var limitReached = false

			let dsg = DispatchGroup()

			for document in documents {
				dsg.enter()

				let username = document.get("followed") as! String

				guard !limitReached else {return}

				self.db.collection("likes")
					.whereField("postID", isEqualTo: postID)
					.whereField("username", isEqualTo: username).getDocuments(completion: { (documents, error) in

						if let documents = documents,
							!limitReached,
							!documents.isEmpty {
							usernames.append(username)
						} 

						if usernames.count == limit {
							print("reached limit \(usernames.count)")
							limitReached = true
						}
						dsg.leave()
					})
			}
			dsg.notify(queue: .main, execute: {
				completion(usernames.count, usernames)
				print("usernames = \(usernames)")

			})

		}
	}

	//MARK: - Comments
	//if parentID is nil then it is a root comment, if not then it's a reply
	func createComment(postID: String, username: String, text: String, parentID: String? = nil) {
		let timestamp = FieldValue.serverTimestamp()
		let commentID = "\(postID)_\(username)\(Timestamp().seconds)"
		let shardsRef = db.collection("counters").document(commentID).collection("shards")
		let commentRef = db.collection("comments").document(commentID)

		db.runTransaction({ (transaction, errorPointer) -> Any? in
			do {
				//create counter with 10 shards
				for i in 0..<10 {
					transaction.setData(["count" : 0], forDocument: shardsRef.document(String(i)))
					transaction.setData([
						"postID" : postID,
						"parentID" : parentID,
						"username" : username,
						"text" : text,
						"timestamp" : timestamp
						], forDocument: commentRef)
				}
			} catch let error as NSError {
				errorPointer?.pointee = error
			}
			return nil
		}) { (object, error) in
			// ...
			if error != nil {
				print(error?.localizedDescription)
			}
		}
	}

	func getReplies(commentID: String, completion: @escaping ([Comment]) -> ()) {
		db.collection("comments")
			.whereField("parentID", isEqualTo: commentID)
			.getDocuments { (snapshot, error) in
				guard error == nil else {
					return
				}
				var comments = [Comment]()
				if let documents = snapshot?.documents {
					for document in documents {
						let data = document.data()
						let parentID = data["parentID"] as? String
						let postID = data["postID"] as! String
						let username = data["username"] as! String
						let text = data["text"] as! String
						let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
						let comment = Comment(parentID: parentID, commentID: document.documentID, postID: postID, username: username, text: text, likes: 1, timestamp: timestamp ?? Date())
						comments.append(comment)
					}
					completion(comments)
				}
		}
	}

	func getComments(postID: String, completion: @escaping ([Comment])->()) {
		print("postID: \(postID)")
		let dsg = DispatchGroup()

		db.collection("comments")
			.whereField("postID", isEqualTo: postID)
			.whereField("parentID", isEqualTo: NSNull())
			.getDocuments { (snapshot, error) in
			guard error == nil else {
				return
			}
			var comments = [Comment]()
			if let documents = snapshot?.documents {

				for document in documents {

					let data = document.data()
					let postID = data["postID"] as! String
					let username = data["username"] as! String
					let text = data["text"] as! String
					let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
					let comment = Comment(parentID: nil, commentID: document.documentID, postID: postID, username: username, text: text, likes: 1, timestamp: timestamp ?? Date())
					dsg.enter()
					self.getReplies(commentID: document.documentID, completion: { (replies) in
						comments.append(comment)
						comments.append(contentsOf: replies)
						dsg.leave()
					})
				}
				dsg.notify(queue: .main, execute: {
					completion(comments)
				})
			}
		}
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

	//MARK: - Get username from uid
	func getUsername(fromUID uid: String, completion: @escaping (String)->()) {
		db.collection("users").document(uid).getDocument { (document, error) in
			guard let document = document else {
				print("Document does not exist")
				return
			}
			if let data = document.data(){
				let username = data["username"] as! String
				completion(username)
			}
		}
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
	func followUser(withUsername followed: String, completion: @escaping ()->()) {
		guard let follower = self.currentUser.username else {return}
		db.collection("relationships").document("\(follower)_\(followed)").setData([
			"follower" : follower,
			"followed" : followed,
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

	func unfollowUser(withUsername followed: String, completion: @escaping ()->()) {
		guard let follower = self.currentUser.username else {return}
		db.collection("relationships").document("\(follower)_\(followed)").delete { (error) in
			guard error == nil else {
				print("error deleting document")
				return
			}
			completion()
		}
	}

	//MARK: - Get followed users
	func getFollowedUsers(for username: String, completion: @escaping ([QueryDocumentSnapshot]) -> ()) {
		db.collection("relationships").whereField("follower", isEqualTo: username).getDocuments { (documents, error) in
			guard error == nil,
				let documents = documents?.documents else {
					print(error?.localizedDescription ?? "Error finding followed users")
					return
			}
			completion(documents)
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
			self.defaults.set(username, forKey: "username")
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
				self.defaults.set(username, forKey: "username")
				completion()
			}
		}
	}

	//MARK: - Retrieve posts
	func getPostsForUser(username: String, limit: Int, lastSnapshot: DocumentSnapshot? = nil, completion: @escaping (_ posts:[ListDiffable]?, _ lastSnapshot: DocumentSnapshot?) -> ()) {

		var query: Query!

		//Pagination
		if lastSnapshot == nil {
			query = db.collection("posts").whereField("username", isEqualTo: username).order(by: "timestamp", descending: true).limit(to: limit)
		} else {
			query = db.collection("posts").whereField("username", isEqualTo: username).order(by: "timestamp", descending: true).start(afterDocument: lastSnapshot!).limit(to: limit)
		}

		query.getDocuments { (documents, error) in
			guard error == nil,
				let documents = documents?.documents else {
					print(error?.localizedDescription ?? "Error fetching posts!")
					return
			}
			var items = [ListDiffable]()
			let dispatchGroup = DispatchGroup()
			
			for document in documents {
				let id = document.documentID
				let username = document.get("username") as! String
				let timestamp = (document.get("timestamp") as? Timestamp)?.dateValue()
				let imageURL = document.get("imageURL") as! String

				var postLikes: Int = 0
				var followedUsernames = [String]()
				var userDidLike = false
				var postComments = [Comment]()

				dispatchGroup.enter()
				let likeCounter = self.db.collection("counters").document(id)
				self.getTotalLikes(ref: likeCounter, completion: { (likes) in
					postLikes = likes
					dispatchGroup.leave()
				})

				dispatchGroup.enter()
				self.getFollowedLikes(postID: id, limit: 2, completion: { (int, usernames) in
					followedUsernames = usernames
					dispatchGroup.leave()
				})

				dispatchGroup.enter()
				self.userDidLikePost(username: self.currentUser.username, postID: id, completion: { (didLike) in
					userDidLike = didLike
					dispatchGroup.leave()
				})

				dispatchGroup.enter()
				self.getComments(postID: id, completion: { (comments) in
					postComments = comments
					dispatchGroup.leave()
				})

				dispatchGroup.notify(queue: .main) {
					let post = Post(
						id: id,
						username: username,
						timestamp: timestamp!,
						imageURL: URL(string: imageURL)!,
						likes: postLikes,
						followedUsernames: followedUsernames,
						didLike: userDidLike,
						comments: postComments
					)
					items.append(post)
				}
			}
			dispatchGroup.notify(queue: .main) {

				let lastSnapshot = documents.last
				completion(items, lastSnapshot)
			}
		}
	}

}

