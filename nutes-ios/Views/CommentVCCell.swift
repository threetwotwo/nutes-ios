//
//  CommentVCCell.swift
//  nutes-ios
//
//  Created by Gary on 12/17/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import IGListKit

class CommentVCCell: UICollectionViewCell, ListBindable {

	@IBOutlet weak var leadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var textLabel: UILabel!
	@IBOutlet weak var timestampLabel: UILabel!

	func bindViewModel(_ viewModel: Any) {
		guard let viewModel = viewModel as? CommentViewModel else { return }
		let attributedText = AttributedText.constructComment(username: viewModel.username, text: viewModel.text)
		textLabel.attributedText = attributedText
		timestampLabel.text = viewModel.timestamp.timeAgoDisplay()
	}
}
