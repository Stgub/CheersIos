//
//  MembershipVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/5/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Stripe
import AFNetworking

class MembershipVC: UIViewController {

    @IBOutlet weak var basicMembershipBtn: UIButton!
    @IBOutlet weak var clubMembershipBtn: UIButton!
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func basicMembershipBtnTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Downgrade clicked", message: "Are you sure you want to downgrade?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive){ (action) in
            print("Wants to downgrade")
            self.unsubscribe()
            
        }
        let noAction = UIAlertAction(title: "No", style: .default) { (action) in
            print("Does not want to downgrade")
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func upgradeBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toPaymentVCSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewDidAppear(_ animated: Bool) {
        if currentUser.membership == membershipLevels.premium{
            basicMembershipBtn.setTitle("Downgrade", for: .normal)
            clubMembershipBtn.setTitle("You're in the club", for: .normal)
            clubMembershipBtn.isUserInteractionEnabled = false
            basicMembershipBtn.isUserInteractionEnabled = true
        } else {
            basicMembershipBtn.setTitle("Your current membership", for: .normal)
            clubMembershipBtn.setTitle("Join the club", for: .normal)
            basicMembershipBtn.isUserInteractionEnabled = false
            clubMembershipBtn.isUserInteractionEnabled = true
        }
    }
    
    func unsubscribe(){
            print("postStripeToken")

        let URL = SERVER_BASE + "/unsubscribeUser"
        
        let params = ["customerId":currentUser.stripeId] as [String:String]
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html","application/json"])
        manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
            if let response = responseObject as? [String: String] {
                if response["Error"] != nil{
                    presentUIAlert(sender: self, title: "Error", message:"Please try again")
                } else {
                    //Protect these
                    let status = response["status"]
                    let message = response["message"]
                    
                    presentUIAlert(sender: self, title: status!, message: message!)
                    if status == "canceled"{
                        currentUser.membership = membershipLevels.basic
                        currentUser.ref.child(userDataTypes.membership).setValue(membershipLevels.basic)
                    }
                }
            }else{ print("Chuck: Could not convert to [String: String]")}

        },
                     failure:
            {
                requestOperation, error in
                print("Chuck: Error -\(error)")
                presentUIAlert(sender: self, title: "Please Try Again", message: (error?.localizedDescription)!)
                
        })
            
        

    }

}
