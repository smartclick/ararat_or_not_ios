//
//  UtilityMethods.swift
//  AraratOrNotExample
//
//  Created by Sevak Soghoyan on 8/4/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation
import UIKit

struct UtilityMethods {
    static func getTextAndColor(withProbabilty probability: Double) -> (String, UIColor) {
        switch probability {
        case 0..<0.65:
            return CheckTitleConstants.itsNotArarat
        case 0.65..<0.75:
            return CheckTitleConstants.probablyArarat
        case 0.75..<0.85:
            return CheckTitleConstants.mostLikelyArarat
        case 0.85..<0.90:
            return CheckTitleConstants.definitelyArarat
        default:
            return CheckTitleConstants.thisIsArarat
        }
    }
}
