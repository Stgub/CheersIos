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
class CreateEmailLoginVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var isMaleSwitch: UISwitch!
    
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    @IBOutlet weak var genderSwitch: UISwitch!
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func signUpBtnPressed(_ sender: Any) {
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

        guard let city = cityField.text else {
            return
        }
        guard let zipCode = zipCodeField.text else {
            return
        }
        let birthday = birthdayPicker.date.timeIntervalSince1970
        var gender = ""
        if isMaleSwitch.isOn {
            gender = "male"
        } else {
            gender = "female"
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                print("Chuck: Successfully authenticated with Firebase and email")
                if let user = user {
                    let userData = [
                        userDataTypes.provider: user.providerID,
                        userDataTypes.name: name ,
                        userDataTypes.email: email,
                        userDataTypes.gender: gender,
                        userDataTypes.birthday: "\(birthday)",
                        "locationCity": city,
                        "locationZipCode":zipCode] 
                    UserService.shareService.completeSignIn(sender: self, id: user.uid, userData: userData)
                }
            } else {
                if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                    switch errCode {
                    case .errorCodeEmailAlreadyInUse:
                        presentUIAlert(sender:self, title: "Email already in use", message: "Please try another email")
                    case .errorCodeInvalidEmail:
                        presentUIAlert(sender:self, title: "Invalid Email", message: "Email is not in the correct format")
                    default:
                        print("Chuck: Erorr signing up with email - \(String(describing: error))")
                        
                    }
                }
            }
        })
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround() // In UIVC extension

        //for hiding keyboard on return 
        passwordField.delegate = self
        emailField.delegate = self
        passwordConfirmField.delegate = self
        nameField.delegate = self
        cityField.delegate = self
        zipCodeField.delegate = self
        
    }
    //Along with setting delegate in viewDidLoad, gets rid of keyboard on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("ShouldReturn")
        textField.resignFirstResponder()
        return false
    }
}
