//
//  ImageViewModel.swift
//  nutes-ios
//
//  Created by Gary on 12/15/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import IGListKit
final class ImageViewModel: ListDiffable {

	let url: URL

	init(url: URL) {
		self.url = url
	}

	func diffIdentifier() -> NSObjectProtocol {
		return "image" as NSObjectProtocol
	}

	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		 guard let object = object as? ImageViewModel else {
			return false
		}
		return self.url == object.url
	}

}
