//
//  UserProfileViewController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import IGListKit
import RealmSwift
import SDWebImage
import FirebaseFirestore

class UserProfileViewController: UIViewController, UICollectionViewDelegate {

	//MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	//MARK: - Variables
	var items: [ListDiffable] = []
	var db: Firestore!

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
		reloadItems()
	}

	override func viewDidAppear(_ animated: Bool) {
//		reloadItems()
	}

	fileprivate func reloadItems() {
		items.removeAll()
		items.append(User(text: "Elon"))

		db = Firestore.firestore()
		db.collection("posts").whereField("username", isEqualTo: User.username).order(by: "timestamp", descending: true).getDocuments { (documents, error) in
			guard error == nil,
			let documents = documents?.documents else {
				print(error?.localizedDescription ?? "Error fetching posts!")
				return
			}

			for document in documents {
				let post = Post()
				post.imageURL = document.get("imageURL") as? String
				self.items.append(post)
			}
			print(self.items.count)
			self.adapter.reloadData(completion: nil)
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
