//
//  AraratOrNot.swift
//  AraratOrNot
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation
import UIKit

public final class AraratOrNot {
    public static func detectAraratOrNot(withImage image: UIImage, completion:@escaping ((Result<ImageResponse,NetworkError>) -> ())) {
        Networking.checkImage(image: image, completion: completion)
    }
    
    public static func detectAraratOrNot(withImageLinkPath imageLink: String, completion:@escaping ((Result<ImageResponse,NetworkError>) -> ())) {
        Networking.checkImageFromUrl(imageUrlLink: imageLink, completion: completion)
    }
    
    public static func sendFeedback(withImageID imageID: String, isCorrect: Bool, completion:@escaping ((Result<MessageResponse,NetworkError>) -> ())) {
        Networking.sendFeedback(imageId: imageID, isCorrect: isCorrect, completion: completion)
    }
}
