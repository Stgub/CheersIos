//
//  SignUpBarIntialVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignUpBarIntialVC: UIViewController, hasDataDict {
    
    @IBAction func signOutBtnTapped(_ sender: Any) {
        
        try! FIRAuth.auth()!.signOut()
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        presentFirstLoginVC(sender: self)
    }
    
    var dataDict: [String : Any] = [:]
    @IBOutlet weak var barNameField: UITextField!
    @IBOutlet weak var streetField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var phoneNumArea: UITextField!
    @IBOutlet weak var phoneNumSecond: UITextField!
    @IBOutlet weak var phoneNumThird: UITextField!
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        let phonenumber = "(\(phoneNumArea.text!)\(phoneNumSecond.text!)-\(phoneNumThird.text!)"
        dataDict[Bar.dataTypes.locationStreet] = streetField.text!
        dataDict[Bar.dataTypes.barName] = barNameField.text!
        dataDict[Bar.dataTypes.locationCity] = cityField.text!
        dataDict[Bar.dataTypes.locationState] = stateField.text!
        dataDict[Bar.dataTypes.locationZipCode] = zipCodeField.text!
        dataDict[Bar.dataTypes.phoneNumber] = phonenumber
    
        self.performSegue(withIdentifier: "nextBarSignUpSegue", sender: self)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            let email = "charlesfayal@gmail.com"
            let pwd = "Gorby123"
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
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                }
            })
        }


    
    
    
    
    func completeSignIn(id:String, userData:Dictionary<String, String>){
        // for automatic sign in
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        print("Signed in")
    }



    // hides keyboard on tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with:event)
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected object to the new view controller.
        let destVC = segue.destination
        switch(destVC){
        case is hasDataDict:
            var dest = destVC as! hasDataDict
            dest.dataDict = self.dataDict
        default:
            print("Default segue")
        }
    }
    

}
