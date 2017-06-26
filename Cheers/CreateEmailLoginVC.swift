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
class CreateEmailLoginVC: UIViewController {

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
                        userDataTypes.birthday: birthday,
                        "locationCity": city,
                        "locationZipCode":zipCode] as [String : Any]
                    
                    self.completeSignIn(id: user.uid, userData: userData)
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
   
    func completeSignIn(id:String, userData:Dictionary<String, Any>){
        // for automatic sign in
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let KeychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Chuck: Data saved to keycahain \(KeychainResult)")
        GeneralFunctions.presentBarFeedVC(sender: self)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
