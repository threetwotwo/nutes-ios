//
//  ActionTimer.swift
//  nutes-ios
//
//  Created by Gary on 12/4/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation

class ActionTimer {

	var resetSeconds: Int!

	var seconds: Int!

	var timer = Timer()

	init(seconds: Int) {
		self.seconds = seconds
		self.resetSeconds = seconds
	}

	func start(completion:@escaping ()->()) {
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true
			, block: { (timer) in
				self.updateTimer {
					completion()
				}
		})
	}

	@objc func updateTimer(completion:()->()) {
		print(self.seconds)
		self.seconds -= 1
		if self.seconds == 0 {
			print("time's up!")
			invalidate()
			reset()
			completion()
		}
	}

	func reset() {
		seconds = resetSeconds
	}

	func invalidate() {
		timer.invalidate()
	}
}
