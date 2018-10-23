//
//  UserProfileHeaderSectionController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class UserProfileHeaderSectionController: ListSectionController {

	override func numberOfItems() -> Int {
		return 1
	}

	override func cellForItem(at index: Int) -> UICollectionViewCell {
		guard let context = collectionContext else { return UICollectionViewCell() }
		let cell = context.dequeueReusableCellFromStoryboard(withIdentifier: "UserProfileHeaderCell", for: self, at: index) as! UserProfileCell
//		let imageHeight = cell.userProfileImage.frame.height
		//Round the corners
//		cell.userProfileImage.layer.cornerRadius = imageHeight/2
//		cell.followButton.layer.cornerRadius = 5
		return cell
	}

	override func sizeForItem(at index: Int) -> CGSize {
		return CGSize(width: collectionContext?.containerSize.width ?? 0, height: 128)
	}
}
