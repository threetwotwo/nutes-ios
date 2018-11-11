//
//  SearchVCUserSectionController.swift
//  nutes-ios
//
//  Created by Gary on 11/10/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit

class SearchVCUserSectionController: ListSectionController {
	var user: User?

	override func didUpdate(to object: Any) {
		guard let user = object as? User else {return}
		self.user = user
	}

	override func numberOfItems() -> Int {
		return 1
	}

	override func cellForItem(at index: Int) -> UICollectionViewCell {
		guard let context = collectionContext,
			let user = user else {
				return SearchVCUserCell()
		}

		let cell = context.dequeueReusableCellFromStoryboard(withIdentifier: "SearchVCUserCell", for: self, at: index) as! SearchVCUserCell

		cell.usernameLabel.text = user.username

		return cell

	}

	override func sizeForItem(at index: Int) -> CGSize {
		guard let frame = collectionContext?.containerSize else { return .zero}
		return CGSize(width: frame.width, height: 40)
	}

	override func didSelectItem(at index: Int) {
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserVC") as! UserViewController
		guard let user = user else {return}
		vc.user = user
		viewController?.navigationController?.pushViewController(vc, animated: true)
		print("didselect \(user.username)")
	}
}
