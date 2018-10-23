//
//  UserProfileNuteSectionController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class UserProfileNuteSectionController: ListSectionController {

	var post: Post?

	//Configure cell bottom margin
	override init() {
		super.init()
		self.minimumInteritemSpacing = 1
		inset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
	}

	override func didUpdate(to object: Any) {
		guard let post = object as? Post else {return}
		self.post = post
	}

	//number of items to be displayed by one cell
	override func numberOfItems() -> Int {
		return 1
	}

	override func cellForItem(at index: Int) -> UICollectionViewCell {
		guard let context = collectionContext,
			let post = post,
			let imageData = post.image else {
				return UICollectionViewCell()
		}


		let cell = context.dequeueReusableCellFromStoryboard(withIdentifier: "UserProfileNuteCell", for: self, at: index)

		guard let nuteCell = cell as? NuteCell else {
			return cell
		}

		if let image = UIImage(data: imageData) {
			nuteCell.imageView.image = image
		}

		return nuteCell
	}

	override func sizeForItem(at index: Int) -> CGSize {
		return self.itemSize
	}

	fileprivate var itemSize: CGSize {
		let collectionViewWidth = collectionContext?.containerSize.width ?? 0
		let itemWidth = ((collectionViewWidth - 2) / 3)
		let heightRatio: CGFloat = 1
		return CGSize(width: itemWidth, height: itemWidth * heightRatio)
	}

	override func didSelectItem(at index: Int) {
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
		vc.post = post
		viewController?.navigationController?.pushViewController(vc, animated: true)
	}
}
