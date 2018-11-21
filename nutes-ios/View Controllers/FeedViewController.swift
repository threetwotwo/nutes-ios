//
//  FeedViewController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import IGListKit

class FeedViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	//MARK: - IBActions
	@IBAction func logout(_ sender: Any) {
		do {
			try Auth.auth().signOut()
			print("User logged out!")
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as! SignupViewController
			self.present(vc, animated: true, completion: nil)
//			self.tabBarController?.dismiss(animated: true, completion: nil)

		} catch {
			print("Unable to logout")
		}
	}

	//MARK: - Adapter
	lazy var adapter: ListAdapter = {
		let updater = ListAdapterUpdater()
		let adapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: 1)
		adapter.collectionView = collectionView
		adapter.dataSource = self
		return adapter
	}()

	//MARK: - Pull to refresh
	lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)

		return refreshControl
	}()

	@objc func handleRefresh(_ refreshControl: UIRefreshControl) {
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
			self.adapter.reloadData()
			refreshControl.endRefreshing()
		}

	}


	//MARK: - Variables
	var items = [ListDiffable]()
	var firestore = FirestoreManager.shared


	override func viewDidLoad() {
        super.viewDidLoad()
		self.collectionView.addSubview(self.refreshControl)

		self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
		//get user's following
		firestore.getFollowedUsers(for: firestore.currentUser.uid) { (documents) in
			for document in documents {
				guard let uid = document.data()["followedID"] as? String else {return}

				self.firestore.getPostsForUser(uid: uid, limit: 3, completion: { (posts) in
					guard let posts = posts else {return}
					for post in posts {
						self.items.append(post)
					}
					self.adapter.reloadData()
				})
			}
		}
    }

}

extension FeedViewController: ListAdapterDataSource {
	func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
		return items
	}

	func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
		return FeedVCSectionController()
	}

	func emptyView(for listAdapter: ListAdapter) -> UIView? {
		return nil
	}


}
