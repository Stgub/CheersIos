//
//  PaymentVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/5/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Stripe
import AFNetworking

class PaymentVC: UIViewController {

    let spinner = UIActivityIndicatorView()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var CVCField: UITextField!
    
    @IBOutlet weak var expirationMonthField: UITextField!
    @IBOutlet weak var expirationYearField: UITextField!
    
    
    @IBAction func purchaseBtnTapped(_ sender: Any) {
        self.view.addSubview(spinner)
        spinner.isHidden = false
        spinner.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        print("tapped purchase")
        // Initiate the card
        let stripCard = STPCardParams()

        if self.cardNumberField.text?.isEmpty == true {
            handleIncompleteInfo(missingInfo: "Card Number")
            return
        }
        if self.emailField.text?.isEmpty == true  {
            handleIncompleteInfo(missingInfo: "Email")

            return
        }
        if self.expirationMonthField.text?.isEmpty == true || self.expirationMonthField.text?.isEmpty == true {
            handleIncompleteInfo(missingInfo: "Expiration Date")
            return
        }
        // Split the expiration date to extract Month & Year
    
        let expMonth = UInt(Int(expirationMonthField.text!)!)
        let expYear = UInt(Int(expirationYearField.text!)!)
        
        if let customerId = currentUser.stripeID {
            
            let URL =  SERVER_BASE + "/subscribeUser"
            let params = ["customerID": customerId ] as [String:String]
            
            let manager = AFHTTPRequestOperationManager()
            manager.responseSerializer.acceptableContentTypes = Set(["text/html","application/json"])
            manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
                if let response = responseObject as? [String: String] {
                    if let error = response["Error"]{
                        print(error)
                    }
                    print("CHUCK: customerId \(customerId))")
                    currentUser.ref.child(userDataTypes.membership).setValue(membershipLevels.premium)
                  //  currentUser.membership = membershipLevels.premium
                    currentUser.ref.child(userDataTypes.stripeId).setValue(customerId, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("Chuck: Error saving stripeId")
                        } else {
                            
                        }
                    })
                    
                    let alertController = UIAlertController(title: response["status"]!, message: response["message"]!, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        let currentDate = Date()
                        let dateFormater = DateFormatter()
                        dateFormater.dateFormat = "MM/dd/yyyy"
                        let currentDateString = dateFormater.string(from: currentDate)
                        currentUser.billingDate = currentDateString
                        currentUser.ref.child(userDataTypes.billingDate).setValue(currentUser.billingDate, withCompletionBlock: { (error, ref) in
                            if error != nil {
                                print("Chuck: error upgrading user's billing date")
                                
                            }
                        })
                        currentUser.ref.child(userDataTypes.membership).setValue(membershipLevels.premium, withCompletionBlock: { (error, ref) in
                            if error != nil {
                                print("Chuck: error upgrading user's membership")
                                
                            }
                        })
                        self.view.isUserInteractionEnabled = true
                        self.dismiss(animated: true, completion: nil)
                        
                        NSLog("Okay Pressed")
                    }
                    self.spinner.stopAnimating()
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            },
                         failure:
                {
                    requestOperation, error in
                    print("Chuck: Error -\(error)")
                    presentUIAlert(sender: self, title: "Please Try Again", message: (error?.localizedDescription)!)
                    self.spinner.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    
            }
                
            )
        } else {
            // Send the card info to Strip to get the token
            stripCard.number = self.cardNumberField.text
            stripCard.cvc = self.CVCField.text
            stripCard.expMonth = expMonth
            stripCard.expYear = expYear
            STPCardValidator.validationState(forCard: stripCard)
            
            STPAPIClient.shared().createToken(withCard: stripCard, completion: { (token, error) -> Void in
                
                if error != nil {
                    self.handleError(error: error! as NSError)
                    return
                }
                
                self.postStripeToken(token: token!)
            })

        }
        
        
    }
    func handleIncompleteInfo(missingInfo:String){
        presentUIAlert(sender: self, title: "No \(missingInfo)", message: "Please add \(missingInfo)")
        spinner.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }

    func handleError(error: NSError) -> Void {
        print("Chuck: Error -\(error)")
        presentUIAlert(sender: self, title: "Please Try Again", message: error.localizedDescription)
        spinner.stopAnimating()
        self.view.isUserInteractionEnabled = true

        
    }
    
    func postStripeToken(token: STPToken) {

        let URL =  SERVER_BASE + "/processDonation"
        let params = ["stripeToken": token.tokenId,
        //"plan" : "premiumSubscription",
        "amount": "1000",
        "currency": "usd",
        "email":self.emailField.text!,
        "description": self.emailField.text!
        ] as [String:String]
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html","application/json"])
        manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
            if let response = responseObject as? [String: String] {
                if let error = response["Error"]{
                    print(error)
                }
                if let customerID = response["customerId"]{
                    print("CHUCK: customerId \(customerID))")
                    currentUser.ref.child(userDataTypes.membership).setValue(membershipLevels.premium)
                 //   currentUser.membership = membershipLevels.premium
                    currentUser.ref.child(userDataTypes.stripeId).setValue(customerID, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("Chuck: Error saving stripeId")
                        } else {
                            
                        }
                    })
                    currentUser.stripeID = customerID
                }
              
                let alertController = UIAlertController(title: response["status"]!, message: response["message"]!, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //upgrade current user to premium
                    let currentDate = Date()
                    let dateFormater = DateFormatter()
                    dateFormater.dateFormat = "MM/dd/yyyy"
                    let currentDateString = dateFormater.string(from: currentDate)
                    currentUser.billingDate = currentDateString
                    currentUser.ref.child(userDataTypes.billingDate).setValue(currentUser.billingDate, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("Chuck: error upgrading user's billing date")
                            
                        }
                    })
                    currentUser.ref.child(userDataTypes.membership).setValue(membershipLevels.premium, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("Chuck: error upgrading user's membership")
                            
                        }
                    })
                    self.view.isUserInteractionEnabled = true
                    self.dismiss(animated: true, completion: nil)

                    NSLog("Okay Pressed")
                }
                self.spinner.stopAnimating()
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        },
            failure:
            {
                requestOperation, error in
                print("Chuck: Error -\(error)")
                presentUIAlert(sender: self, title: "Please Try Again", message: (error?.localizedDescription)!)
                self.spinner.stopAnimating()
                self.view.isUserInteractionEnabled = true

        }
        
        )
    }

    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }



}
