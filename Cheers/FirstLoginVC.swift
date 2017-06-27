//
//  LogInOrSignUpVC.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import SwiftKeychainWrapper

class FirstLoginVC: UIViewController {

    @IBAction func fbBtnTapped(_ sender: UIButton) {
        UserService.shareService.facebookLogIn(sender: self)
    }

}
