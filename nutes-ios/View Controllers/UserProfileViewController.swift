//
//  UserProfileViewController.swift
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

class UserProfileViewController: UIViewController, UICollectionViewDelegate {

	//MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	//MARK: - Variables
	var items: [ListDiffable] = []
	var db: Firestore!
	var user = User()

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
		db = FirebaseManager.shared.db
		if let uid = Auth.auth().currentUser?.uid {
			db.collection("users").document(uid).getDocument { (document, error) in
				if let document = document, document.exists,
					let postCount = document.get("posts") as? Int{
					self.user.posts = postCount
				} else {
					print("Document does not exist")
				}
			}
		}
		reloadItems()
		NotificationCenter.default.addObserver(self, selector: #selector(reloadItems), name: NSNotification.Name(rawValue: "postuploadsuccess"), object: nil)
	}

	@objc fileprivate func reloadItems() {
		items.removeAll()
		items.append(user)

		FirebaseManager.shared.getPostsForUser(username: User.username) { (posts) in
			guard let posts = posts else {return}
			self.items.append(contentsOf: posts)
			self.adapter.reloadData()
		}
	}

}

//MARK: - Data Source
extension UserProfileViewController: ListAdapterDataSource {

	func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
		return items
	}

	func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
		switch object {
		case is User:
			return UserProfileHeaderSectionController()
		default:
			return UserProfileNuteSectionController()
		}
	}

	func emptyView(for listAdapter: ListAdapter) -> UIView? {
		return nil
	}

}
