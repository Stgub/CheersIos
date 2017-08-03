//
//  AccountVC.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class AccountVC: BaseMenuVC, UITextFieldDelegate{
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private var serverRequestInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.serverRequestInProgress {
                    self.view.isUserInteractionEnabled = false
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.isHidden = false
                }
                else {
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }, completion: nil)
        }
    }
    
    private var isBasicMembership:Bool = true {
        didSet {
            if self.isBasicMembership {
                membershiBtn.backgroundColor = TOAST_PRIMARY_COLOR
                membershiBtn.setTitle("Join the club", for: .normal)
            } else {
                membershiBtn.backgroundColor = UIColor.lightGray
                membershiBtn.setTitle("Downgrade", for: .normal)
            }
        }
    }
    
    private var currentlyEditing :Bool = false
    {
        didSet{
            if currentlyEditing {
                editBtn.setTitle("Done", for: .normal)
                emailTF.isHidden = false
                nameTF.isHidden = false
                usernameLabel.isHidden = true
                userEmailLabel.isHidden = true
            } else
            {
                editBtn.setTitle("Edit", for: .normal)
                emailTF.isHidden = true
                nameTF.isHidden = true
                usernameLabel.isHidden = false
                userEmailLabel.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var leftMenuButton: UIButton!
    @IBOutlet weak var membershiBtn: UIButton!
    @IBOutlet weak var membershipLabel: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    
    
    @IBAction func membershipBtnTapped(_ sender: Any) {
        if(isBasicMembership){
            self.userWantsToUpgrade()
        } else {
            self.userWantsToDowngrade()
        }
    }

    @IBAction func editBtnTapped(_ sender: Any) {
        if currentlyEditing
        {
            var userData:Dictionary<String,AnyObject> = [:]
            let name = nameTF.text!
            let email = emailTF.text!
            if !name.isEmpty{
                usernameLabel.text = name
                userData[userDataTypes.name] = name as AnyObject
            }
            if !email.isEmpty {
                userEmailLabel.text = email
                userData[userDataTypes.email] = email as AnyObject

            }
            UserService.sharedService.updateUser(data:[userDataTypes.name:name])
        }
        currentlyEditing = !currentlyEditing
        
    }
    
    
    @IBAction func logOutBtnTapped(_ sender: Any) {
        print("Log out btn tapped")
        UserService.sharedService.signOut()
        GeneralFunctions.presentFirstLoginVC(sender:self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
          updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround() // In UIVC extension
        nameTF.delegate = self
        emailTF.delegate = self
        
        attachMenuButton(menuButton: leftMenuButton)
        self.activityIndicator.isHidden = true
        self.activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }

    func updateUI()
    {
        if let currentUser = UserService.sharedService.getCurrentUser()
        {
            isBasicMembership = currentUser.membership == membershipLevels.basic
            membershipLabel.text = currentUser.membership
            usernameLabel.text = currentUser.name
            if let email = currentUser.userEmail {
                userEmailLabel.text = email
            }
        }

    }

    func userWantsToUpgrade(){
        self.performSegue(withIdentifier: "toCheckoutVCSegue", sender: self)
    }
    
    func userWantsToDowngrade(){
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
    

    func unsubscribe(){
        serverRequestInProgress = true
        StripeAPIClient.sharedClient.unusubscribeCustomer { (status, message) in
            presentUIAlert(sender: self, title: status, message: message){
                self.updateUI()
            }
            self.serverRequestInProgress = false
        }
    }
    
}
