//
//  PhoneVerificationVC.swift
//  Cheers
//
//  Created by Charles Fayal on 6/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import FirebaseAuth

class PhoneVerificationVC: ScreenWithBackButtonVC {

    @IBOutlet weak var phoneNum1TF: UITextField!
    
    @IBOutlet weak var phoneNum2TF: UITextField!
    
    @IBOutlet weak var PhoneNum3TF: UITextField!
    

    @IBAction func verifyBtnTapped(_ sender: Any) {
        
        let phoneNumber = phoneNum1TF.text! + phoneNum2TF.text! + PhoneNum3TF.text!
        //TODO verify phone number ? 
        //cant figure out how to use PhoneVerify
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
