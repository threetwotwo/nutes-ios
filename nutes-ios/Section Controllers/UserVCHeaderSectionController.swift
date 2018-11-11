//
//  UserVCHeaderSectionController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class UserVCHeaderSectionController: ListSectionController {
	var user: User?

	override func didUpdate(to object: Any) {
		guard let user = object as? User else {return}
		self.user = user
	}
	
	override func numberOfItems() -> Int {
		return 1
	}

	override func cellForItem(at index: Int) -> UICollectionViewCell {
		guard let context = collectionContext else { return UICollectionViewCell() }
		let cell = context.dequeueReusableCellFromStoryboard(withIdentifier: "UserProfileHeaderCell", for: self, at: index) as! UserProfileCell
		let imageHeight = cell.userProfileImage.frame.height
		//Round the corners
		cell.userProfileImage.layer.cornerRadius = imageHeight/2
		//update labels
		cell.postLabel.text = "\(user?.posts ?? 0)"
		return cell
	}

	override func sizeForItem(at index: Int) -> CGSize {
		return CGSize(width: collectionContext?.containerSize.width ?? 0, height: 128)
	}
}
