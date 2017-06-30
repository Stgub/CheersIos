//
//  ReferralVC.swift
//  Cheers
//
//  Created by Charles Fayal on 5/19/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit



class ReferralVC: BaseMenuVC { //, PLDLinkNavigationControllerDelegate {
    @IBOutlet weak var leftMenuButton: UIButton!

    
    var asyncUIHandler:AsyncUIHandler!
    

    
    @IBAction func checkoutBtnTapped(_ sender: Any) {
        PaypalAPIClient.sharedClient.createPayout(amount: 10, recipient_type: "PHONE", receiver: "860-941-5547") { (error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print("Successful checkout")
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        attachMenuButton(menuButton: leftMenuButton)
        asyncUIHandler = AsyncUIHandler(vc: self)
        // Do any additional setup after loading the view.
    }
    
  
}
