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

class UserProfileViewController: UIViewController, UICollectionViewDelegate {

	//MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	//MARK: - Variables
	var items: [ListDiffable] = []

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

	}

	override func viewDidAppear(_ animated: Bool) {
		guard !items.isEmpty else {return}
		items.removeAll()
		adapter.reloadData(completion: nil)
	}

	fileprivate func reloadItems() {
		items.append(User(text: "Elon"))
		let realm = try! Realm()
		let posts = realm.objects(Post.self).sorted(byKeyPath: "timestamp", ascending: false)
		for post in posts {
			items.append(post)
		}
	}

}

//MARK: - Data Source
extension UserProfileViewController: ListAdapterDataSource {

	func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
		reloadItems()
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
