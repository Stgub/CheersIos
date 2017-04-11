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
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: RoundedImageCorner!
    @IBOutlet weak var membershipLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    
    @IBOutlet weak var renewsDateLabel: UILabel!
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
        self.performSegue(withIdentifier: "toCheckoutVCSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        
    }
    
    func updateUI(){
        
        self.usernameLabel.text = currentUser.name
        self.creditsLabel.text = "\(currentUser.credits!)"
        self.membershipLabel.text = currentUser.membership
        if let userImage = currentUser.usersImage {
            self.userImageView.image = currentUser.usersImage
        }
        
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
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    func unsubscribe(){
         let myAPIClient = MyAPIClient.sharedClient
         myAPIClient.unusubscribeCustomer { (status, message) in
            presentUIAlert(sender: self, title: status, message: message)
            self.updateUI()
        }
  
        

    }

}
