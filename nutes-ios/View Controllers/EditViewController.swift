//
//  EditViewController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class EditViewController: UIViewController, UITextViewDelegate {

	//MARK: - IBOutlets
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var doneButton: UIButton!
	@IBOutlet weak var hideKeyboardButton: UIButton!
	@IBOutlet weak var textLabel: UITextView!
	@IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
	@IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageView: UIView!

	//MARK: - Variables

	//MARK: - IBActions
	@IBAction func cancelButtonTapped(_ sender: Any) {
		textLabel.resignFirstResponder()
		self.dismiss(animated: true, completion: nil)
	}

	fileprivate func hideKeyboard(completion: ((Bool)->())? = nil) {

		UIView.animate(withDuration: 0.3, animations: {
			self.hideKeyboardButton.isHidden = true
			self.doneButtonBottomConstraint.constant = 16
			self.keyboardViewHeight.constant = 0
			self.textLabel.resignFirstResponder()
			self.view.layoutIfNeeded()
		}, completion: completion)
	}

	@IBAction func hideKeyboardButtonTapped(_ sender: UIButton) {
		hideKeyboard()
	}

	@IBAction func doneButtonTapped(_ sender: UIButton) {
		guard let text = self.textLabel.text,
			text.count > 0 else {return}
		doneButton.isEnabled = false
		hideKeyboard { (_) in
			UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, self.imageView.isOpaque, 0.0)

			self.imageView.drawHierarchy(in: self.imageView.bounds, afterScreenUpdates: true)

			guard let image = UIGraphicsGetImageFromCurrentImageContext(),
				let imageData = image.jpegData(compressionQuality: 1),
				let username = FirestoreManager.shared.currentUser.username else {return}

			UIGraphicsEndImageContext()

			//Create unique id
			let timestamp = FieldValue.serverTimestamp()
			let postID = "\(username)\(Timestamp.init().seconds)"
			//Create reference to Cloud Storage
			let imageRef = Storage.storage().reference().child(postID + ".jpg")
			imageRef.putData(imageData, metadata: nil) { (metadata, error) in
				imageRef.downloadURL(completion: { (URL, error) in
					guard error == nil else {
						print(error?.localizedDescription ?? "Error uploading")
						return
					}
					if let url = URL?.absoluteString {
						let db = FirestoreManager.shared.db

						db!.collection("posts").document(postID).setData([
							"uid" : FirestoreManager.shared.currentUser.uid,
							"username" : username,
							"imageURL" : url,
							"timestamp" : timestamp
						]){
							error in
							guard error == nil else {
								print(error?.localizedDescription ?? "Error adding document")
								return
							}

							print("post added with ID: \(username)")

							//notifies the app that a post has been uploaded to cloud storage
//							NotificationCenter.default.post(name: NSNotification.Name(rawValue: "postuploadsuccess"), object: nil)
							//increment user's post count
							guard let userID = Auth.auth().currentUser?.uid else {return}
							let user = db!.collection("users").document(userID)
							user.getDocument { (document, error) in
								guard let document = document,
									let postCount = document.get("posts") as? Int else {
										print("Document does not exist")
										return
								}
								user.updateData(["posts" : postCount + 1])
							}
						}
					}
				})
			}
		}
		self.dismiss(animated: true, completion: nil)
	}

	//MARK: - Life Cycle
	fileprivate func showKeyboard(_ notification: (Notification)) {

		UIView.animate(withDuration: 0.3) {
			self.hideKeyboardButton.isHidden = false
			self.doneButtonBottomConstraint.constant = 64
			let frame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
			self.keyboardViewHeight.constant = frame.height
			self.view.layoutIfNeeded()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		doneButton.isEnabled = true

		textLabel.font = UIFont.systemFont(ofSize: UIScreen.main.bounds.width/13.8, weight: .semibold)
		self.textLabel.spellCheckingType = .no

		NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { (notification: Notification) in
			// Any code you put in here will be called when the keyboard is about to display
			print("Show keyboard!")
			self.showKeyboard(notification)
		}

		//		NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { (notification: Notification) in
		//			// Any code you put in here will be called when the keyboard is about to hide
		//			self.hideKeyboard()
		//		}

	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)

		//Selects text view for editing when view appears
		textLabel.becomeFirstResponder()
		print("View did appear")

	}

	func textViewDidBeginEditing(_ textView: UITextView) {
		print(Notification(name: UIResponder.keyboardWillShowNotification))
	}
}



