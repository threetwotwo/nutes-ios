//
//  ImageCell.swift
//  nutes-ios
//
//  Created by Gary on 12/15/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import IGListKit

class ImageCell: UICollectionViewCell, ListBindable {

	@IBOutlet weak var imageView: UIImageView!

	func bindViewModel(_ viewModel: Any) {

		guard let viewModel = viewModel as? ImageViewModel else { return }

		imageView.sd_setImage(with: viewModel.url)
	}

}
