//
//  ActionCell.swift
//  nutes-ios
//
//  Created by Gary on 12/15/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import IGListKit

protocol ActionCellDelegate: class {
	func didTapHeart(cell: ActionCell)
}

class ActionCell: UICollectionViewCell, ListBindable {

	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var likesLabel: UILabel!

	weak var delegate: ActionCellDelegate? = nil

	func bindViewModel(_ viewModel: Any) {
		guard let viewModel = viewModel as? ActionViewModel else { return }
		likesLabel.text  = "\(viewModel.likes) likes"
		let image = viewModel.didLike ? "heart_filled" : "heart_bordered"
		likeButton.setImage(UIImage(named: image), for: [])
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		likeButton.addTarget(self, action: #selector(onHeart), for: .touchUpInside)
	}

	@objc func onHeart() {
		delegate?.didTapHeart(cell: self)
	}
}
