//
//  EndpointType.swift
//  AraratOrNot
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public protocol EndpointType {

    var baseURL: URL { get }

    var path: String { get }

}
