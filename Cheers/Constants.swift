//
//  Constants.swift
//  Cheers
//
//  Created by Steven Graf on 2/26/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

let SHADOW_GRAY: CGFloat = 120.0 / 255.0

let TOAST_PRIMARY_COLOR = UIColor(colorLiteralRed: 255/255, green: 128/255, blue: 0, alpha: 1)

let KEY_UID = "uid"
let TIME_BETWEEN_DRINKS:TimeInterval = 90 * 60// in seconds

enum notificationKeys:String {
    case userObserver = "userObserver"
}

let DAY_IN_SECS:TimeInterval = 24*60*60
struct myStoryboards {
    static let  main = "Main"
    static let logOrSignIn = "LoginFlow"
    static let splash = "Splash"
    static let menu = "Menu"
    static let addBarFlow = "AddBarFlow"
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
    static let allDays:[weekDays] = [.Sunday,.Monday,.Tuesday,.Wednesday,.Thursday,.Friday,.Saturday]

}
