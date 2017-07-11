//
//  contactUsVC.swift
//  Cheers
//
//  Created by Steven Graf on 3/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class ContactUsVC: BaseMenuVC {

    @IBOutlet weak var leftMenuButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachMenuButton(menuButton: leftMenuButton)
    }
    
    
    //Send to email
    @IBAction func emailBtnTapped(_ sender: Any) {
        let email = "contact@thetoastclub.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.openURL(url)
            
        }
    }
    


}
