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

    var verifyId = ""

    private enum phoneVerifyState {
        case phoneNum
        case enterCode
    }
    
    private var state: phoneVerifyState = .phoneNum {
        didSet{
            if state == .phoneNum {
                enterPhoneSV.isHidden = false
                enterCodeSV.isHidden = true
            } else if state == .enterCode {
                enterPhoneSV.isHidden = true
                enterCodeSV.isHidden = false
            }
        }
    }

    
    @IBOutlet weak var enterCodeSV: UIStackView!
    @IBOutlet weak var enterPhoneSV: UIStackView!
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var phoneNum1TF: UITextField!
    @IBOutlet weak var phoneNum2TF: UITextField!
    @IBOutlet weak var phoneNum3TF: UITextField!
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func verifyBtnTapped(_ sender: Any) {
        print("verifying")
        guard let num1 = phoneNum1TF.text, let num2 = phoneNum3TF.text , let num3 = phoneNum3TF.text,  !num1.isEmpty && !num2.isEmpty && !num3.isEmpty else {
            presentUIAlert(sender: self, title: "Did not enter full number", message: "Please complete number")
            return
        }
        let phoneNumber = "+1" + phoneNum1TF.text! + phoneNum2TF.text! + phoneNum3TF.text!
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber) { (verificationID, error) in
            if error != nil {
                print("Error verifying phone num \(error.debugDescription)")
            } else {
                self.verifyId = verificationID!
                print("Phone verification complete, sending SMS")
                self.state = .enterCode
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
                currentUser.phoneNumber = user?.phoneNumber
                self.dismiss(animated: true, completion: nil)
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.state = .phoneNum
        hideKeyboardWhenTappedAround()
        UIApplication.shared.registerForRemoteNotifications() // needed for phone verification

    }

}
