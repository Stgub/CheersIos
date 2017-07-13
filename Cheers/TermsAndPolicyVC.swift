//
//  TermsAndPolicyVC.swift
//  Cheers
//
//  Created by Charles Fayal on 6/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class TermsAndPolicyVC: BaseMenuVC {
    @IBOutlet weak var leftMenuBtn: UIButton!

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attachMenuButton(menuButton: leftMenuBtn)
        webView.loadRequest(URLRequest(url: URL(string:ConfigUtil.PRIVACY_POLICY_URL)!))
    }

 

}
