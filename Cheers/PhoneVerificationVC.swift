//
//  PhoneVerificationVC.swift
//  Cheers
//
//  Created by Charles Fayal on 6/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import FirebaseAuth

class PhoneVerificationVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var codeTF: UITextField!
    var verifyId = ""
    
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func verifyBtnTapped(_ sender: Any) {
        print("verifying")
        let phoneNumber = "+18609415547"
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { (verificationID, error) in
            if error != nil {
                print("Error verifying phone num \(error.debugDescription)")
            } else {
                self.verifyId = verificationID!
                self.pressedVerify()
            }
            
        }
    }
    
    
    @IBAction func Done(_ sender: Any) {
        let code = codeTF.text!
        print("Entered Code: \(code)")
        let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verifyId,
                verificationCode: code)
        print(credential)
        Auth.auth().currentUser?.link(with: credential, completion: { (user, error) in
            if let err = error {
                presentUIAlert(sender: self, title: "Error", message: err.localizedDescription)
                print("Error authenticating phone num \(err.localizedDescription)")
            } else {
                print("Successfully added users phone number- \(String(describing: user?.phoneNumber))")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    func pressedVerify(){
        print(#function)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [/*.badge, .sound, .alert*/], categories: nil))

        UIApplication.shared.registerForRemoteNotifications()

    }

}
