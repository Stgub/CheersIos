//
//  AddBankVC.swift
//  Cheers
//
//  Created by Charles Fayal on 5/24/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Stripe


class AddBankVC: UIViewController {

    //TODO add waiting spinnner
    @IBOutlet weak var bankNameTF: UITextField!
    @IBOutlet weak var accountNumTF: UITextField!
    @IBOutlet weak var routingNumTF: UITextField!
    
    
    @IBOutlet weak var userFullNameTF: UITextField!
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBankBtnTapped(_ sender: Any) {
        let bankName = bankNameTF.text!
        let accountNum = accountNumTF.text!
        let routingNum = routingNumTF.text!
        let userName = userFullNameTF.text!
        if bankName.isEmpty || accountNum.isEmpty || routingNum.isEmpty || userName.isEmpty {
            presentUIAlert(sender: self, title: "Empty fields", message: "Please fill out all fields")
        } else {
        
            let bankAccount = STPBankAccountParams()
            bankAccount.accountHolderName = userName
            bankAccount.accountHolderType = STPBankAccountHolderType.individual
            bankAccount.accountNumber = accountNum
            bankAccount.routingNumber = routingNum
            bankAccount.country = "US"
            bankAccount.currency = "usd"

            
            
//            StripeAPIClient.sharedClient.connectAddBank(bankParams: bankAccount, completion: { (error) in
//                if(error == nil ){
//                    print("Successfully added bank")
//                    presentUIAlert(sender: self, title: "Success", message: "Bank account added", returnBlock: {
//                        self.dismiss(animated: true, completion: nil)
//                    })
//                } else {
//                    presentUIAlert(sender: self, title: "Error", message: error!.localizedDescription)
//                }
//            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
