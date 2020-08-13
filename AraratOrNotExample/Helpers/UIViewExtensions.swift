//
//  UIViewExtensions.swift
//  AraratOrNotExample
//
//  Created by Sevak Soghoyan on 8/13/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImageWith(newSizeValue: CGFloat) -> UIImage? {
        var newWidth = newSizeValue
        var newHeight = newSizeValue
        if size.width > size.height {
            let scale = newWidth / size.width
            newHeight = size.height * scale
        } else {
            let scale = newHeight / size.height
            newWidth = size.width * scale
        }
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
