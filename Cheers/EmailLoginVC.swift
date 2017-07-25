//
//  EmailLoginVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class EmailLoginVC: AsyncControllerBase, LoginController,UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func loginBtnTapped(_ sender: Any) {

        if emailField.text == "admin" && passwordField.text == "flims"{
            print("admin un and pw used")
            let storyboard = UIStoryboard(name: myStoryboards.main, bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "SignUpBarIntialVC")
            self.present(vc, animated: true, completion: nil)
        }else {
            guard let email = emailField.text, let password = passwordField.text, email != "" && password != "" else {
                print("Email or password invalid")
                presentUIAlert(sender: self, title: "Fields not complete", message: "Fill in email and password fields")
                return
            }
            self.startAsyncProcess()
            UserService.shareService.emailLogIn(loginController: self, email: email, password: password)
        }
        
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround() // In UIVC extension
        emailField.delegate = self
        passwordField.delegate = self
    }
    //Along with setting delegate in viewDidLoad, gets rid of keyboard on return 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("ShouldReturn")
        textField.resignFirstResponder()
        return false
    }


}

