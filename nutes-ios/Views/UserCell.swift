//
//  UserCell.swift
//  nutes-ios
//
//  Created by Gary on 12/15/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import IGListKit

class UserCell: UICollectionViewCell, ListBindable {


	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var usernameLabel: UILabel!

	func bindViewModel(_ viewModel: Any) {
		guard let viewModel = viewModel as? UserViewModel else { return }
		usernameLabel.text = viewModel.username
	}

}
