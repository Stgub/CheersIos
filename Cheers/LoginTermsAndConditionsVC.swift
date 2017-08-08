//
//  LoginTermsAndConditionsVC.swift
//  
//
//  Created by Charles Fayal on 8/7/17.
//
//

import UIKit

class LoginTermsAndConditionsVC: UIViewController {

    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var webView: UIWebView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(URLRequest(url: URL(string:ConfigUtil.TERMS_AND_CONDITIONS_URL)!))
    }
    

    

}
