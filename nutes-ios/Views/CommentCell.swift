//
//  CommentCell.swift
//  nutes-ios
//
//  Created by Gary on 12/16/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import IGListKit

class CommentCell: UICollectionViewCell, ListBindable {

	@IBOutlet weak var textLabel: UILabel!

	func bindViewModel(_ viewModel: Any) {
		guard let viewModel = viewModel as? Comment else { return }
		textLabel.attributedText = AttributedText.constructComment(username: viewModel.username, text: viewModel.text)
	}
}
