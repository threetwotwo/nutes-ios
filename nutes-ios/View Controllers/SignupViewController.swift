//
//  SignupViewController.swift
//  nutes-ios
//
//  Created by Gary on 10/24/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignupViewController: UIViewController {

	//MARK: - IBOutlets
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var signupButton: UIButton!
	@IBOutlet weak var changeSignupModeButton: UIButton!
	@IBOutlet weak var usernameMessageLabel: UILabel!
	
	//MARK: - IBActions
	fileprivate func updateUsernameMessage(using username: String) {
		guard isSignupMode else {return}
		let docRef = self.db.collection("usernames").document(username)
		docRef.getDocument { (document, error) in
			guard error == nil,
			let document = document else {
				print(error?.localizedDescription ?? "error in fetching document")
				return
			}

			var message = ""

			if document.exists {
				message = "username taken"
				self.signupButton.isEnabled = false
			} else {
				message = "✓"
				self.signupButton.isEnabled = true
			}
			self.usernameMessageLabel.text = message
		}
	}

	@IBAction func usernameFieldChanged(_ sender: UITextField) {
		guard sender.text != "" else {return}
		self.usernameMessageLabel.text = ""
	}

	@IBAction func signupButtonPressed(_ sender: Any) {

		guard usernameField.text != "",
		let username = usernameField.text else {return}

		let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainscreen") as! UITabBarController

		if isSignupMode {
			Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (authResult, error) in
				guard error == nil else {
					print(error?.localizedDescription ?? "error in creating user")
					return
				}
				// Add a new document with a generated ID
				guard let email = authResult?.user.email,
					let uid = Auth.auth().currentUser?.uid else { return }

				self.db.collection("usernames").document(username).setData([
					"user" : uid,
					"email" : email
				]) {
					error in
					if let error = error {
						print("Error adding document: \(error)")
					} else {
						print("username Document added with ID: \(username)")
					}
				}

				self.db.collection("users").document(uid).setData([
					"email" : email,
					"username" : username,
					"timestamp" : FieldValue.serverTimestamp(),
					"posts" : 0,
					"followers" : 0,
					"following" : 0
				]) { error in
					if let error = error {
						print("Error adding document: \(error)")
					} else {
						print("user Document added with ID: \(uid)")
					}
				}
				print("\(String(describing: authResult?.user.email)) registered!")
				User.username = username
				User.uid = Auth.auth().currentUser?.uid
				self.present(vc, animated: true)
			}
		} else {
			let docRef = self.db.collection("usernames").document(username)
			docRef.getDocument { (document, error) in
				guard error == nil else {return}
				if let document = document, document.exists  {
					guard let email = document.get("email") as? String else {return}
					Auth.auth().signIn(withEmail: email, password: self.passwordField.text!) { (result, error) in
						guard error == nil else {
							print(error?.localizedDescription ?? "error in logging in")
							return
						}
						print("\(username) logged in!")
						User.username = username
						User.uid = Auth.auth().currentUser?.uid
						self.present(vc, animated: true)
					}
				}
			}
		}
	}

	@IBAction func changeSignupModeButtonPressed(_ sender: Any) {
		isSignupMode = !isSignupMode
		usernameMessageLabel.text = ""
		updateButtons()
	}

	//MARK: - variablesr
	var db: Firestore!
	var isSignupMode = true
	var usernameTaken = true

	fileprivate func updateButtons() {
		emailField.isHidden = !isSignupMode
		signupButton.isEnabled = !isSignupMode
		signupButton.setTitle(isSignupMode ? "Sign Up" : "Login", for: [])
		changeSignupModeButton.setTitle(isSignupMode ? "Already have an account?" : "Don't have an account?", for: [])
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		updateButtons()
		usernameMessageLabel.text = ""
		usernameField.delegate = self
		db = FirebaseManager.shared.db
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		signupButton.isEnabled = !isSignupMode
	}
}

extension SignupViewController: UITextFieldDelegate {

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		signupButton.isEnabled = !isSignupMode
		return true
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		guard usernameField.text != "",
		let username = usernameField.text else {return true}
		updateUsernameMessage(using: username)
		return true
	}
}

