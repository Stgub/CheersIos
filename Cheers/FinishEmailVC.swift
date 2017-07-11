//
//  FinishEmailVC.swift
//  Cheers
//
//  Created by Charles Fayal on 7/11/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class FinishEmailVC: UIViewController,hasDataDict, UITextFieldDelegate{
    var dataDict: [String : Any] = [:]
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var isMaleSwitch: UISwitch!
    
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func signUpBtnPressed(_ sender: Any) {
             guard let zipCode = zipCodeField.text else {
            return
        }
        guard let email = dataDict[userDataTypes.email] as? String else {
            return
        }
        guard let password = dataDict["password"] as? String else {
            return
        }
        let birthday = birthdayPicker.date.timeIntervalSince1970
        var gender = ""
        if isMaleSwitch.isOn {
            gender = "male"
        } else {
            gender = "female"
        }
    
        var userData = [
            userDataTypes.gender: gender,
            userDataTypes.birthday: "\(birthday)",
            "locationZipCode":zipCode]
        userData[userDataTypes.name] = dataDict[userDataTypes.name] as? String
        userData[userDataTypes.email] = email
        UserService.shareService.emailSignUp(sender:self, email: email, password: password, userData:userData)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround() // In UIVC extension
        
        //for hiding keyboard on return
        zipCodeField.delegate = self
        
    }
    //Along with setting delegate in viewDidLoad, gets rid of keyboard on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("ShouldReturn")
        textField.resignFirstResponder()
        return false
    }

}
