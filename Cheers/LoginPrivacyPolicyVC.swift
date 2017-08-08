//
//  LoginPrivacyPolicyVC.swift
//  Cheers
//
//  Created by Charles Fayal on 8/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class LoginPrivacyPolicyVC: UIViewController {
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(URLRequest(url: URL(string:ConfigUtil.PRIVACY_POLICY_URL)!))
    }

}
