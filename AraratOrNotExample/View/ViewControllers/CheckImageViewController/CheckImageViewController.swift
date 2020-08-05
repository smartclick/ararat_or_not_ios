//
//  CheckImageViewController.swift
//  AraratOrNotExample
//
//  Created by Sevak Soghoyan on 8/4/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit
import AraratOrNot

enum CheckImageViewControllerType {
    case imageCheck(image: UIImage)
    case linkCheck(imageUrlStr: String)
}

//MARK:- Properties
class CheckImageViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var feedbackContainerView: UIView!
    @IBOutlet weak var checkImageContainerView: UIView!
    @IBOutlet weak var feedbackContainerViewTopConstraint: NSLayoutConstraint!
    
    private var type:CheckImageViewControllerType!
    private var checkImageResponse: ImageResponse? {
        didSet {
            updateUIAfterResponse()
        }
    }
}

//MARK:- View Lifecycle
extension CheckImageViewController {
    convenience init(withType type: CheckImageViewControllerType) {
        self.init()
        self.type = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
}

//MARK:- IBActions
extension CheckImageViewController {
    @IBAction func correctButtonAction(_ sender: Any) {
        sendFeedback(isCorrect: true)
    }
    
    @IBAction func incorrectButtonAction(_ sender: Any) {
        sendFeedback(isCorrect: false)
    }
    
    @IBAction func checkButtonAction(_ sender: Any) {
        guard checkImageResponse == nil else {
            dismiss(animated: true)
            return
        }
        activityIndicatorView.startAnimating()
        switch type {
        case .imageCheck(let image):
            checkAraratOrNot(withImage: image)
        case .linkCheck(let imageUrlStr):
            checkAraratOrNot(withUrlPath: imageUrlStr)
        case .none:
            return
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- Private methods
extension CheckImageViewController {
    func updateUI() {
        if #available(iOS 13.0, *) {
            activityIndicatorView.style = .large
        } else {
            activityIndicatorView.style = .whiteLarge
        }
        checkButton.layer.cornerRadius = 25
        checkImageContainerView.layer.cornerRadius = 25
        switch type {
        case .imageCheck(let image):
            previewImageView.image = image
        case .linkCheck(let imageUrlStr):
            updateUI(withImageUrl: imageUrlStr)
        case .none:
            return
        }
    }
    
    private func updateUI(withImageUrl imageUrlStr: String) {
        let url = URL(string: imageUrlStr)!
        activityIndicatorView.startAnimating()
        checkImageContainerView.isHidden = true
        previewImageView.load(url: url,completion: { isSuccess in
            if !isSuccess {
                self.showWrongUrlAlert()
            } else {
                self.checkImageContainerView.isHidden = false
            }
            self.activityIndicatorView.stopAnimating()
        })    
    }
    
    private func showWrongUrlAlert() {
        showAlert(withMessage: "Wrong URL") {
            self.dismiss(animated: true)
        }
    }
    
    func updateUIAfterResponse() {
        guard let imageResponse = checkImageResponse else {
            return
        }
        let responseColorText = UtilityMethods.getTextAndColor(withProbabilty: imageResponse.probability)
        resultLabel.text = responseColorText.0
        resultLabel.textColor = responseColorText.1
        checkButton.setTitle("Check another image", for: .normal)
        animateFeedbackContainerView(isShow: true)
        cancelButton.isHidden = true
    }
    
    
    private func checkAraratOrNot(withUrlPath urlPath: String) {        
        AraratOrNot.detectAraratOrNot(withImageLinkPath: urlPath) { [unowned self] result in
            DispatchQueue.main.async {
                self.checkResponse(withResutl: result)
            }
        }
    }
    
    private func checkAraratOrNot(withImage image: UIImage) {
        guard let imageData = image.pngData() else {
            showAlert(withMessage: "Wrong Image")
            return
        }
        AraratOrNot.detectAraratOrNot(withImageData: imageData) { [unowned self] result in
            DispatchQueue.main.async {
                self.checkResponse(withResutl: result)
            }
        }
    }
    
    private func checkResponse(withResutl result: Result<ImageResponse,NetworkError>) {
        activityIndicatorView.stopAnimating()
        switch result {
        case .success(let imResponse):
            checkImageResponse = imResponse
        case .failure(let networkError):
            switch networkError {
            case .apiError(let message):
                showAlert(withMessage: message)
            default:
                showAlert(withMessage: networkError.localizedDescription)
            }
        }
    }
    
    private func sendFeedback(isCorrect: Bool) {
        guard let imageResponse = checkImageResponse else {
            return
        }
        activityIndicatorView.startAnimating()
        AraratOrNot.sendFeedback(withImageID: imageResponse.id, isCorrect: isCorrect) { (result) in
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                switch result {
                case .success( _):
                    self.animateFeedbackContainerView(isShow: false)
                case .failure(let networkError):
                    switch networkError {
                    case .apiError(let message):
                        self.showAlert(withMessage: message)
                    default:
                        self.showAlert(withMessage: networkError.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func animateFeedbackContainerView(isShow: Bool) {
        feedbackContainerViewTopConstraint.constant = isShow ? UIConstants.feebackContainerDefaultTopConstraint + feedbackContainerView.frame.height : UIConstants.feebackContainerDefaultTopConstraint
        let alpha: CGFloat = isShow ? 1 : 0
        UIView.animate(withDuration: 0.5) {
            self.feedbackContainerView.alpha = alpha
            self.view.layoutIfNeeded()
        }
    }
}
