//
//  NSMutableAttributedString + bold.swift
//  nutes-ios
//
//  Created by Gary on 11/29/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
	@discardableResult func bold(_ text: String) -> NSMutableAttributedString {
		let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 15)]
		let boldString = NSMutableAttributedString(string:text, attributes: attrs)
		append(boldString)

		return self
	}

	@discardableResult func normal(_ text: String) -> NSMutableAttributedString {
		let normal = NSAttributedString(string: text)
		append(normal)

		return self
	}
}
