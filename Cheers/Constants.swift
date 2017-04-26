//
//  Constants.swift
//  Cheers
//
//  Created by Steven Graf on 2/26/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

let SHADOW_GRAY: CGFloat = 120.0 / 255.0


let KEY_UID = "uid"
let TIME_BETWEEN_DRINKS:TimeInterval = 90 * 60// in seconds

struct myStoryboards {
    static let  main = "Main"
    static let logOrSignIn = "SignOrLogin"
 
}


enum weekDays: Int {
    case Sunday = 1
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
    
    var toString: String {
        return String(describing: self)
    }
}
