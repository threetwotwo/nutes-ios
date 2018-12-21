//
//  UserVCNuteSectionController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit
import SDWebImage

class UserVCNuteSectionController: ListSectionController {

	var post: Post?

	//Configure cell bottom margin
	override init() {
		super.init()
		self.minimumInteritemSpacing = 2
		inset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
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
			let post = post else {
				return UICollectionViewCell()
		}

		let cell = context.dequeueReusableCellFromStoryboard(withIdentifier: "UserProfileNuteCell", for: self, at: index)

		guard let nuteCell = cell as? NuteCell else {
			return cell
		}

		nuteCell.imageView.sd_setImage(with: post.imageURL)
		return nuteCell
	}

	override func sizeForItem(at index: Int) -> CGSize {
		return self.itemSize
	}

	fileprivate var itemSize: CGSize {
		let collectionViewWidth = collectionContext?.containerSize.width ?? 0
		let itemWidth = ((collectionViewWidth - 4) / 3)
		let heightRatio: CGFloat = 1
		return CGSize(width: itemWidth, height: itemWidth * heightRatio)
	}

	override func didSelectItem(at index: Int) {
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
		vc.post = post
		viewController?.navigationController?.pushViewController(vc, animated: true)
	}
}
