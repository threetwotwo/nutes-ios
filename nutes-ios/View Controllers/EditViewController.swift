//
//  EditViewController.swift
//  nutes-ios
//
//  Created by Gary on 10/23/18.
//  Copyright © 2018 Gary. All rights reserved.
//

import UIKit
import RealmSwift

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

	fileprivate func hideKeyboard() {
		UIView.animate(withDuration: 0.3) {
			self.hideKeyboardButton.isHidden = true
			self.doneButtonBottomConstraint.constant = 16
			self.view.layoutIfNeeded()
		}
	}

	@IBAction func hideKeyboardButtonTapped(_ sender: UIButton) {
		textLabel.resignFirstResponder()

		hideKeyboard()
	}

	@IBAction func doneButtonTapped(_ sender: UIButton) {
		textLabel.resignFirstResponder()
		view.layoutIfNeeded()
		guard let text = textLabel.text,
			text.count > 0 else {return}
		let renderer = UIGraphicsImageRenderer(size: imageView.bounds.size)
		let image = renderer.image { ctx in
			imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
		}
		let imageData = image.jpegData(compressionQuality: 1)

		let post = Post()
		post.username = "elonofficial"
		post.image = imageData
		let realm = try! Realm()
		try! realm.write {
			realm.add(post)
		}
	}

	//MARK: - Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()

		textLabel.font = UIFont.systemFont(ofSize: UIScreen.main.bounds.width/13.8, weight: .semibold)

		NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { (notification: Notification) in
			// Any code you put in here will be called when the keyboard is about to display
			print("Show keyboard!")
			self.showKeyboard()
			let frame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

			self.keyboardViewHeight.constant = frame.height
		}

		NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { (notification: Notification) in
			// Any code you put in here will be called when the keyboard is about to hide
			self.keyboardViewHeight.constant = 0
		}

	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)

		//Selects text view for editing when view appears
		textLabel.becomeFirstResponder()
		print("View did appear")

	}

	fileprivate func showKeyboard() {
		UIView.animate(withDuration: 0.3) {
			self.hideKeyboardButton.isHidden = false
			self.doneButtonBottomConstraint.constant = 64
			self.view.layoutIfNeeded()
		}
	}

	func textViewDidBeginEditing(_ textView: UITextView) {
		showKeyboard()
	}
}



