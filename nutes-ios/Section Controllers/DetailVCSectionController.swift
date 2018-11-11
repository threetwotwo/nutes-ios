//
//  DetailVCSectionController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class DetailVCSectionController: ListSectionController {
	var post: Post?

	override func didUpdate(to object: Any) {
		guard let post = object as? Post else {return}
		self.post = post
	}

	override func numberOfItems() -> Int {
		return 1
	}

	override func cellForItem(at index: Int) -> UICollectionViewCell {
		guard let context = collectionContext,
			let post = post else {
				return UICollectionViewCell()
		}

		let cell = context.dequeueReusableCellFromStoryboard(withIdentifier: "NuteBigCell", for: self, at: index) as! DetailVCNuteCell
		if let imageURL = URL(string: post.imageURL!) {
			cell.imageView.sd_setImage(with: imageURL)
		}
		return cell
	}

	override func sizeForItem(at index: Int) -> CGSize {
		guard let frame = collectionContext?.containerSize else { return .zero}
		return CGSize(width: frame.width, height: frame.height)
	}
}