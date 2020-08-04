//
//  ViewControllerExtension.swift
//  AraratOrNotExample
//
//  Created by Sevak Soghoyan on 8/4/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(withMessage message: String, okAction:(() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle:UIAlertController.Style.alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
        { action -> Void in
            okAction?()
        })
        present(alertController, animated: true)
    }
}
