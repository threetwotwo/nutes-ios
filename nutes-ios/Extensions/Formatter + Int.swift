//
//  Formatter + Int.swift
//  nutes-ios
//
//  Created by Gary on 12/3/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
extension Formatter {
	static let withSeparator: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.groupingSeparator = "."
		formatter.numberStyle = .decimal
		return formatter
	}()
}

extension BinaryInteger {
	var formattedWithSeparator: String {
		return Formatter.withSeparator.string(for: self) ?? ""
	}
}
