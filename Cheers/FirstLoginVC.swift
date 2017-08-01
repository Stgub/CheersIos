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

class FirstLoginVC: AsyncControllerBase, LoginController {

    @IBAction func fbBtnTapped(_ sender: UIButton) {
        self.startAsyncProcess()
        UserService.sharedService.facebookLogIn(loginController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //Call backs from Userservice when login fails or succeeds
    func loginComplete(){
        self.stopAsyncProcess()
        GeneralFunctions.presentBarFeedVC(sender: self)
    }
    func loginFailed(title: String, message: String) {
        self.stopAsyncProcess()
        presentUIAlert(sender: self, title: title, message: message)
    }
}
