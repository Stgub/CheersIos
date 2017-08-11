//
//  ConfigUtil.swift
//  Cheers
//
//  Created by Charles Fayal on 7/6/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation

class ConfigUtil{
    public static let MONTH_IN_SEC:TimeInterval = 60*60*24*30
    public static let PREMIUM_NUM_CREDITS = 30
    public static let BASIC_NUM_CREDITS = 1 
    public static let CONTACT_EMAIL = "Contact@TheToastClub.com"
    
    public static let PRIVACY_POLICY_URL = "http://www.thetoastclub.com/privacy-policy/"
    public static let TERMS_AND_CONDITIONS_URL = "http://thetoastclub.com/terms-and-conditions/"
    public static let FAQ_URL = "http://www.thetoastclub.com/faq/"
    
    static let SERVER_BASE = "http://ec2-34-202-232-113.compute-1.amazonaws.com:5000"   // AWS server 34.202.232.113*
    //static let SERVER_BASE = "http://0.0.0.0:5000" //local test
    
    static let STRIPE_DEV_KEY =  "pk_test_vbIvPl0JdKlVqMlrILx3A8Sf" //test
    static let STRIPE_PROD_KEY = "pk_live_PuYngGgOA2VX11E7NqNZ1vW3" // Live
    static let APPLE_PAY_ID = "merchant.com.toast.stripe"
    static let verifyPhoneOn = false
    static let inTesting = true
    // true means no phone verification and test stripe keys
    // true uses test stripe IDs instead of normal stripe ids for from firebase 
    
    
}
