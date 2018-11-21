//
//  FeedVCSpinnerSectionController.swift
//  nutes-ios
//
//  Created by Gary on 11/19/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class FeedVCSpinnerSectionController: ListSectionController {

	override func numberOfItems() -> Int {
		return 1
	}

	override func cellForItem(at index: Int) -> UICollectionViewCell {
		guard let context = collectionContext else
		{
			return UICollectionViewCell()
		}

		let cell = context.dequeueReusableCellFromStoryboard(withIdentifier: "FeedSpinnerCell", for: self, at: index) as! DetailVCNuteCell
	
		return cell
	}

	override func sizeForItem(at index: Int) -> CGSize {
		guard let frame = collectionContext?.containerSize else { return .zero}
		return CGSize(width: frame.width, height: 48)
	}
}

