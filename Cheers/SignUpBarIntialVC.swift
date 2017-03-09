//
//  SignUpBarIntialVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class SignUpBarIntialVC: UIViewController, hasDataDict {
    var dataDict: [String : Any] = [:]
    @IBOutlet weak var barNameField: UITextField!
    @IBOutlet weak var streetField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        
        dataDict[Bar.dataTypes.locationStreet] = streetField.text!
        dataDict[Bar.dataTypes.barName] = barNameField.text!
        dataDict[Bar.dataTypes.locationCity] = cityField.text!
        dataDict[Bar.dataTypes.locationState] = stateField.text!
        dataDict[Bar.dataTypes.locationZipCode] = zipCodeField.text!
        dataDict[Bar.dataTypes.phoneNumber] = phoneNumberField.text!
    
        self.performSegue(withIdentifier: "nextBarSignUpSegue", sender: self)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
