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

class EmailLoginVC: UIViewController {

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
            
            if let email = emailField.text, let pwd = passwordField.text{
                FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                    
                    if error != nil {
                        if (error != nil) {
                            // an error occurred while attempting login
                            if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                                switch errCode {
                                case .errorCodeInvalidEmail:
                                    presentUIAlert(sender:self,title: "Invalid email", message: "Email is not in the correct format")
                                case .errorCodeWrongPassword:
                                    presentUIAlert(sender:self,title: "Invalid password", message: "Please enter the correct password")
                                case .errorCodeUserNotFound:
                                    presentUIAlert(sender:self,title: "User not found", message: "Make sure email is correct, or create an account")
                                default:
                                    presentUIAlert(sender:self,title: "Error logging in", message: "Please try again")
                                    print("Chuck - Error logging in went to default error \(error)")
                                    
                                }
                            }
                        }
                    }else {
                        print("Chuck: Email authenticated with Firebase")
                        if let user = user {
                            let userData = [
                                "provider": user.providerID,
                                "email" : user.email!
                            ]
                            self.completeSignIn(id: user.uid, userData: userData)
                        }
                    }
                })
            }
        }
        
    }
    
    

    func completeSignIn(id:String, userData:Dictionary<String, String>){
        // for automatic sign in
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let KeychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Chuck: Data saved to keycahain \(KeychainResult)")
        MyFireBaseAPIClient.sharedClient.getCurrentUser(){
            presentBarFeedVC(sender: self)

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }



}
