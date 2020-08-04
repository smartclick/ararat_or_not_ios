//
//  MessageResponse.swift
//  AraratOrNot
//
//  Created by Sevak Soghoyan on 8/4/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public struct MessageResponse: Decodable {
    public var message: String?
    public var error: String?
}
