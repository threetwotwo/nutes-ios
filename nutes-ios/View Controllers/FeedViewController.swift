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
			let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpVC") as! SignupViewController
			self.present(vc, animated: true, completion: nil)
//			self.tabBarController?.dismiss(animated: true, completion: nil)

		} catch {
			print("Unable to logout")
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
    }

}
