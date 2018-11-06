//
//  FeedViewController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FeedViewController: UIViewController {

	@IBAction func logout(_ sender: Any) {
		do {
			try Auth.auth().signOut()
			print("User logged out!")
			self.tabBarController?.dismiss(animated: true, completion: nil)
		} catch {
			print("Unable to logout")
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
		title = User.username
    }

}
