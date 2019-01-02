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

	//MARK: - IBActions
	@IBAction func followButtonPressed(_ sender: UIButton) {
		print("pressed follow button")

		guard let user = user,
			let followed = user.username else {return}

		if user.isFollowing {
			firestore.unfollowUser(withUsername: followed) {
				self.user?.isFollowing = false
				self.reloadHeader()
			}
		} else {
			firestore.followUser(withUsername: followed) {
				self.user?.isFollowing = true
				self.reloadHeader()
			}
		}
	}

	//MARK: - Variables
	var items: [ListDiffable] = []
	var firestore = FirestoreManager.shared
	var user: User?
	var listener: ListenerRegistration!

	let spinToken = "spinner"
	var lastSnapshot: DocumentSnapshot?
	var loading = false
	var endOfList = false

	//MARK: - Adapter
	lazy var adapter: ListAdapter = {
		let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 1)
		adapter.collectionView = collectionView
		adapter.dataSource = self
		adapter.scrollViewDelegate = self
		return adapter
	}()

	//MARK: - Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		_ = adapter

		if user == nil {
			self.user = firestore.currentUser
		}
		items.append(user!)
		print(user?.username)
		title = user?.username

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)

		//once user is not nill, load header.
		//load posts once header has finished loading
		
		loadHeader {
			self.loadPosts()
		}

		guard let follower = firestore.currentUser.username,
			let followed = user?.username else {return}
		firestore.db.collection("relationships").document("\(follower)_\(followed)").getDocument { (document, error) in
			guard error == nil else {
				print(error?.localizedDescription ?? "Error finding document")
				self.user?.isFollowing = false
				return
			}
			if let document = document, document.exists {
				print("isfollowing")
				self.user?.isFollowing = true
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		listener.remove()
	}

	//MARK: - Data fetching
	@objc fileprivate func loadHeader(completion: @escaping ()->()) {
		guard let user = user else {return}

		listener = firestore.addUserListener(username: user.username) { (data) in
			let posts = data["posts"] as! Int
			print(posts)
			self.user?.posts = posts
			self.items[0] = self.user!

			completion()
		}
	}

	@objc fileprivate func reloadHeader() {
		self.adapter.collectionView?.reloadSections([0])
	}


	@objc fileprivate func loadPosts() {
		guard let user = user else {return}

		firestore.getPostsForUser(username: user.username, limit: 18, lastSnapshot: self.lastSnapshot) { posts, lastSnapshot in
			guard let posts = posts else {return}
			
			self.items.append(contentsOf: posts)
			if let lastSnapshot = lastSnapshot {
				self.lastSnapshot = lastSnapshot
			}
//			self.adapter.reloadData(completion: nil)
			self.adapter.performUpdates(animated: true)
		}
	}

}

//MARK: - Data Source
extension UserViewController: ListAdapterDataSource {

	func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
		var objects = items as [ListDiffable]

		if loading {
			objects.append(spinToken as ListDiffable)
		}

		return objects
	}

	func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
		if let obj = object as? String, obj == spinToken {
			return spinnerSectionController()
		}
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

extension UserViewController: UIScrollViewDelegate {
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
		if !loading && distance < 200 {
			loading = true
			adapter.performUpdates(animated: true, completion: nil)
			DispatchQueue.global(qos: .default).async {
				DispatchQueue.main.async {
					self.loading = false
					self.loadPosts()
				}
			}
		}
	}
}
