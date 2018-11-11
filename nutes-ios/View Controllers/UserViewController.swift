//
//  UserViewController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import IGListKit
import SDWebImage
import FirebaseFirestore
import FirebaseAuth

class UserViewController: UIViewController, UICollectionViewDelegate {

	//MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	@IBAction func followButtonPressed(_ sender: UIButton) {
		print("pressed follow button")
		guard let followerID = firestore.uid,
			let followedID = user?.uid else {return}
		firestore.db.collection("relationships").document("\(followerID)_\(followedID)").setData([
			"followerID" : followerID,
			"followedID" : followedID,
			"timestamp" : FieldValue.serverTimestamp()
		]) { error in
			if let error = error {
				print("Error adding document: \(error)")
			} else {
				print("Document added")
				
			}
		}
	}

	//MARK: - Variables
	var items: [ListDiffable] = []
	var db: Firestore!
	var firestore = FirestoreManager.shared
	var user: User?

	//MARK: - Adapter
	lazy var adapter: ListAdapter = {
		let updater = ListAdapterUpdater()
		let adapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: 1)
		adapter.collectionView = collectionView
		adapter.dataSource = self
		return adapter
	}()

	//MARK: - Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		_ = adapter
		self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
		db = FirestoreManager.shared.db
		NotificationCenter.default.addObserver(self, selector: #selector(reloadItems), name: NSNotification.Name(rawValue: "postuploadsuccess"), object: nil)
		guard let user = user else {
			FirestoreManager.shared.getUserInfo(uid: firestore.uid) { (data) in
				let posts = data["posts"] as! Int
				self.user = User()
				self.user?.posts = posts
				self.user?.uid = self.firestore.uid
				self.user?.username = self.firestore.username

				self.reloadItems()
			}
			return
		}
		FirestoreManager.shared.getUserInfo(uid: user.uid) { (data) in
			let posts = data["posts"] as! Int
			self.user?.posts = posts
			self.reloadItems()
		}

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		guard let user = user else {return}
		guard let followerID = firestore.uid,
			let followedID = user.uid else {return}
		firestore.db.collection("relationships").document("\(followerID)_\(followedID)").getDocument { (document, error) in
			guard error == nil else {
					print(error?.localizedDescription ?? "Error finding document")
					return
			}
			if let document = document, document.exists {
				print("isfollowing")
				self.user?.isFollowing = true
				self.reloadItems()
			}
		}
	}

	@objc fileprivate func reloadItems() {
		items.removeAll()
		items.append(user!)

		firestore.getPostsForUser(username: (user?.username)!) { (posts) in
			guard let posts = posts else {return}
			self.items.append(contentsOf: posts)
			self.adapter.reloadData()
		}
	}

}

//MARK: - Data Source
extension UserViewController: ListAdapterDataSource {

	func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
		return items
	}

	func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
		switch object {
		case is User:
			return UserVCHeaderSectionController()
		default:
			return UserVCNuteSectionController()
		}
	}

	func emptyView(for listAdapter: ListAdapter) -> UIView? {
		return nil
	}

}
