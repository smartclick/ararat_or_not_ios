//
//  IAraratAPI.swift
//  AraratOrNot
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public enum IAraratAPI {
    case feedback(imageId: String)
    case image
}

extension IAraratAPI: EndpointType {
    public var baseURL: URL {
        return URL(string: "https://api.iararat.am")!
    }

    public var path: String {
        switch self {
        case .image:
            return ""
        case .feedback(let imageId):
            return "/image/\(imageId)"
        }
    }
}
