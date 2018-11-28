//
//  Counter.swift
//  nutes-ios
//
//  Created by Gary on 11/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import Foundation
import FirebaseFirestore

// counters/${ID}
struct Counter {
	let numShards: Int

	init(numShards: Int) {
		self.numShards = numShards
	}
}

// counters/${ID}/shards/${NUM}
struct Shard {
	let count: Int

	init(count: Int) {
		self.count = count
	}
}


