//
//  RecommendBarVC.swift
//  Cheers
//
//  Created by Charles Fayal on 6/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//


import UIKit

class RecommendBarVC: BaseMenuVC {
    
  
    @IBOutlet weak var leftMenuBtn: UIButton!
    override func viewDidLoad() {
        attachMenuButton(menuButton: leftMenuBtn)

    }

    //Send to email
    @IBAction func emailBtnTapped(_ sender: Any) {
        let email = "contact@thetoastclub.com"
        if let url = URL(string: "mailto:\(email)") {
                UIApplication.shared.openURL(url)
        }
    }
    
    
    
}
