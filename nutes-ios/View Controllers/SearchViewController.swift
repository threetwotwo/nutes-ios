//
//  SearchViewController.swift
//  nutes-ios
//
//  Created by Gary on 11/9/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import IGListKit

class SearchViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	//MARK: - Variables
	var items: [ListDiffable] = []
	var firestore = FirestoreManager.shared

	//MARK: - Adapter
	lazy var adapter: ListAdapter = {
		let updater = ListAdapterUpdater()
		let adapter = ListAdapter(updater: updater, viewController: self, workingRangeSize: 1)
		adapter.collectionView = collectionView
		adapter.dataSource = self
		return adapter
	}()

	//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
		firestore.db.collection("users").getDocuments { (documents, error) in
			guard error == nil,
			let documents = documents?.documents else {
				print(error?.localizedDescription ?? "Error getting users")
				return
			}
			for document in documents {
				guard let posts = document.get("posts") as? Int,
					let username = document.get("username") as? String else {return}
				let user = User(uid: document.documentID, username: username , posts: posts)
				print(user.username)
				self.items.append(user)
			}
			self.adapter.reloadData()
		}
    }

}


//MARK: - Data Source
extension SearchViewController: ListAdapterDataSource {

	func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
		return items
	}

	func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
		return SearchVCUserSectionController()
	}

	func emptyView(for listAdapter: ListAdapter) -> UIView? {
		return nil
	}

}
