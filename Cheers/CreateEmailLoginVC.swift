//
//  CreateEmailLoginVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/8/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
class CreateEmailLoginVC:AsyncControllerBase, LoginController,UITextFieldDelegate {

    var userData:[String:AnyObject] = [:]
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var nameField: UITextField!
      @IBAction func backBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        guard let email = emailField.text else {
            print("Email error")
            return
        }
        guard let password = passwordField.text, let passwordConfirm = passwordConfirmField.text, !password.isEmpty && !passwordConfirm.isEmpty else  {
            presentUIAlert(sender: self, title: "No password", message: "Please fill out passwords")
            print("Password error")
            return
        }
        if password != passwordConfirm {
            presentUIAlert(sender: self, title: "Passwords do not match", message: "Passwords must match")
            return
        }
    
        guard let name = nameField.text else {
            presentUIAlert(sender: self, title: "Fields not filled out", message: "Please fill out all fields")
            return
        }

          userData = [
            userDataTypes.name: name as AnyObject ,
            userDataTypes.email: email as AnyObject,
            "password": password as AnyObject
            ]
        self.startAsyncProcess()
        UserService.sharedService.emailSignUp(loginController:self as! LoginController, email: email, password: password, userData:userData as! [String : String])
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

        //for hiding keyboard on return 
        passwordField.delegate = self
        emailField.delegate = self
        passwordConfirmField.delegate = self
        nameField.delegate = self
    }
    //Along with setting delegate in viewDidLoad, gets rid of keyboard on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("ShouldReturn")
        textField.resignFirstResponder()
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        if var destVC = dest as? hasDataDict {
            destVC.dataDict = userData
        }
    }
}
