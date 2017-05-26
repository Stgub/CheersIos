//
//  ReferralVC.swift
//  Cheers
//
//  Created by Charles Fayal on 5/19/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import plaid_ios_link
import plaid_ios_sdk


class ReferralVC: UIViewController, PLDLinkNavigationControllerDelegate {

    @IBOutlet weak var bankAccountNameL: UILabel!
    
    let myAPIClient = MyAPIClient.sharedClient
    var asyncUIHandler:AsyncUIHandler!
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkoutBtnTapped(_ sender: Any) {
        
    }

    override func viewDidAppear(_ animated: Bool) {
        asyncUIHandler.asyncInProgress = true
        if currentUser.connectId == nil {
            myAPIClient.createConnectAccount(){
                error in
                self.asyncUIHandler.asyncInProgress = false

                if error == nil {
                    print("created Account")
                } else {
                    print("Error: \(String(describing: error?.localizedDescription))")
                }
            };
        } else {
            myAPIClient.getBankAccounts(completion: {
                (error) in
                self.asyncUIHandler.asyncInProgress = false
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    print("Got bank accounts")
                    let accounts = currentUser.bankAccounts
                    if accounts.count > 0 {
                        let (bankNum,bankInfo) = accounts.first!
                        print(bankInfo)
                        if let bankInfo = bankInfo as? [String:Any] {
                            let bankName = bankInfo["bankName"]
                            self.bankAccountNameL.text = "\(bankName!):\(bankNum)"
                        }
                    }
             
                    
                }
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        asyncUIHandler = AsyncUIHandler(vc: self)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func plaidConnectButton(_ sender: Any) {
        let plaidLink = PLDLinkNavigationViewController(environment: .tartan, product: .connect)!

        plaidLink.linkDelegate = self
        plaidLink.providesPresentationContextTransitionStyle = true
        plaidLink.definesPresentationContext = true
        plaidLink.modalPresentationStyle = .custom
        
        self.present(plaidLink, animated: true, completion: nil)
    }
    
    
    func linkNavigationContoller(_ navigationController: PLDLinkNavigationViewController!, didFinishWithAccessToken accessToken: String!) {
        print("success \(accessToken)")
        myAPIClient.connectAddBank(bankToken: accessToken, completion:{
            (error) in
            if(error != nil) {
                print(error.debugDescription)
            } else {
                print("successfully added bank")
                self.dismiss(animated: true, completion: nil)
            }
        })

    }

    func linkNavigationControllerDidFinish(withBankNotListed navigationController: PLDLinkNavigationViewController!) {
        print("Manually enter bank info?")
        self.performSegue(withIdentifier: "unlistedBankSegue", sender: self)
    }
    
    func linkNavigationControllerDidCancel(_ navigationController: PLDLinkNavigationViewController!) {
        self.dismiss(animated: true, completion: nil)
    }


}
