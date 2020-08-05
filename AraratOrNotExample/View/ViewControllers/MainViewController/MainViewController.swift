//
//  ImageViewController.swift
//  ArararatOrNotExample
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

// MARK:- Properties
class MainViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageUrlTextField: UITextField!
    @IBOutlet weak var urlContainerView: UIView!
}

// MARK:- View Lifecycle
extension MainViewController {        
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
}

// MARK:- IBActions
extension MainViewController {
    @IBAction func selectImageButtonAction(_ sender: Any) {
        presentAlrertController()
    }
    
    @IBAction func goButtonAction(_ sender: Any) {
        guard let text = imageUrlTextField.text, text.count > 0,let _ = URL(string: text) else {
            showAlert(withMessage: "Wrong URL")
            return
        }
        presentCheckImageView(type: .linkCheck(imageUrlStr: text))
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK:- Private methods
extension MainViewController {
    private func updateUI() {
        urlContainerView.layer.cornerRadius = 25
        urlContainerView.layer.borderColor = UIColor(named: "orange")?.cgColor
        urlContainerView.layer.borderWidth = 1.0
        addTapGesture()
    }
    
    func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    private func presentAlrertController() {
        dismissKeyboard()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        { action -> Void in
            self.presentImagePicker(sourceType: .camera)
        })
        alertController.addAction(UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        { action -> Void in
            self.presentImagePicker(sourceType: .photoLibrary)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        { action -> Void in
            alertController.dismiss(animated: true)
        })
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view //to set the source of your alert
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        present(alertController, animated: true)
    }
    
    private func presentCheckImageView(type: CheckImageViewControllerType) {
        dismissKeyboard()
        let checkImageVC = CheckImageViewController(withType: type)
        checkImageVC.modalPresentationStyle = .overCurrentContext
        checkImageVC.modalTransitionStyle = .crossDissolve
        present(checkImageVC, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        dismissKeyboard()
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourceType
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK:- UITextFieldDelegate methods
extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        imageUrlTextField.resignFirstResponder()
        guard let text = imageUrlTextField.text, text.count > 0 else {
            showAlert(withMessage: "Wrong URL")
            return true
        }
        presentCheckImageView(type: .linkCheck(imageUrlStr: text))
        return true
    }
}

// MARK:- UIImagePickerControllerDelegate methods
extension MainViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        guard selectedImage != nil else {
            return
        }
        picker.dismiss(animated: true, completion: {
            self.presentCheckImageView(type: .imageCheck(image: selectedImage!))
        })
    }
}

extension MainViewController {
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        if scrollView.contentOffset.y == 0, let keyboardSize = keyboardSize {
            scrollView.contentOffset.y += keyboardSize.height
            scrollView.isScrollEnabled = true
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
            scrollView.isScrollEnabled = false
        }
    }
    
}
