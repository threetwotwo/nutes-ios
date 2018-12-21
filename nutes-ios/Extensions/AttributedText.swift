//
//  AttributedText.swift
//  nutes-ios
//
//  Created by Gary on 12/16/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

struct AttributedText {
	static func constructLikesLabel(totalLikes: Int, followedLikes: Int, followedUsernames: [String]) -> NSMutableAttributedString {
		let result = NSMutableAttributedString()

		if followedLikes == 0 {
			return result.bold(totalLikes.formattedWithSeparator).normal(" likes")
		} else {
			let followedString = followedUsernames.joined(separator: ", ")
			let othersNumber = totalLikes - followedLikes

			let andString = othersNumber == 0 ? "" : " and "
			let othersString = othersNumber == 0 ? "" :  "\(othersNumber.formattedWithSeparator) others"

			return result.normal("Liked by ").bold(followedString).normal(andString).bold(othersString)
		}
	}

	static func constructComment(username: String, text: String) -> NSMutableAttributedString {
		let result = NSMutableAttributedString()

		return result.bold(username).normal(" ").normal(text)
	}
}
