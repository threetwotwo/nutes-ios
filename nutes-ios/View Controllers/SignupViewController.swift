//
//  SignupViewController.swift
//  nutes-ios
//
//  Created by Gary on 10/24/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var signupButton: UIButton!
	@IBOutlet weak var changeSignupModeButton: UIButton!

	//MARK: - IBActions
	@IBAction func signupButtonPressed(_ sender: Any) {
		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainscreen") as! UITabBarController
		
		if isSignupMode {
			Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (authResult, error) in
				guard error == nil else {
					print(error?.localizedDescription)
					return
				}
				print("\(authResult?.user) registered!")

				self.present(vc, animated: true)
			}
		} else {
			Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { (result, error) in
				guard error == nil else {
					print(error?.localizedDescription)
					return
				}
				print("\(result?.user.email) logged in!")
				self.present(vc, animated: true)
			}
		}
	}

	@IBAction func changeSignupModeButtonPressed(_ sender: Any) {
		isSignupMode = !isSignupMode
		updateButtons()
	}

	//MARK: - variables
	var isSignupMode = true

	fileprivate func updateButtons() {
		signupButton.setTitle(isSignupMode ? "Sign Up" : "Login", for: [])
		changeSignupModeButton.setTitle(isSignupMode ? "Already have an account?" : "Don't have an account?", for: [])
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		updateButtons()

        // Do any additional setup after loading the view.
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)

	}
}
