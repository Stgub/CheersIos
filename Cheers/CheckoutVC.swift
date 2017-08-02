//
//  CheckoutVC.swift
//  Cheers
//
//  Created by Charles Fayal on 4/4/17.
//  Copyright © 2017 Cheers. All rights reserved.
//
import UIKit
import Stripe

class CheckoutViewController: AsyncControllerBase, STPPaymentContextDelegate {
    

       let backendBaseURL: String? = ConfigUtil.SERVER_BASE
    
   // Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
    let appleMerchantID: String? = "merchant.com.toast.stripe"
    //STPPaymentConfiguration.shared().appleMerchantIdentifier = "merchant.com.toast.stripe"

    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = "Toast LLC"
    let paymentCurrency = "usd"
    
    let paymentContext: STPPaymentContext

    
    let myAPIClient = StripeAPIClient.sharedClient
    let theme:STPTheme =  STPTheme.default()

    var product = "Premium Toast Membership"

    
    @IBOutlet weak var purchaseBtnView: UIView!
    @IBAction func choosePaymentOptionsBtnTapped(_ sender: Any) {
        self.paymentContext.presentPaymentMethodsViewController()    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func payBtnTapped(_ sender: Any) {
        self.startAsyncProcess()
        self.paymentContext.requestPayment()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
    }
   

    required init?(coder aDecoder: NSCoder) {
       // fatalError("init(coder:) has not been implemented")
        self.paymentContext = STPPaymentContext(apiAdapter: myAPIClient)
        super.init(coder: aDecoder)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        self.paymentContext.paymentAmount = 1000 // This is in cents, i.e. $50 USD

    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
      //  self.paymentRow.loading = paymentContext.loading
        if let paymentMethod = paymentContext.selectedPaymentMethod {
            //self.paymentRow.detail = paymentMethod.label
            purchaseBtnView.isHidden = false
            print("Payment label \(String(describing: paymentMethod))")
        }
        else {
            purchaseBtnView.isHidden = true
            //self.paymentRow.detail = "Select Payment"
        }

    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didCreatePaymentResult paymentResult: STPPaymentResult,
                        completion: @escaping STPErrorBlock) {
        myAPIClient.createCharge(paymentResult, amount: 1000, completion: { (error: Error?) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFinishWith status: STPPaymentStatus,
                        error: Error?) {
        var title:String = ""
        var message:String = ""
        switch status {
        case .error:
            print("Backend: didfinishWith error - \(error?.localizedDescription)")
            title = "Error"
            message = error!.localizedDescription
            completePurchase(title: title, message: message, error: error)
        case .success:
            UserService.sharedService.updateUserMembership(membership: membershipLevels.premium)
            title = "Success"
            message = "Welcome to the premium membership!"
            
            self.completePurchase(title: title, message: message, error: nil)
            
        case .userCancellation:
            self.stopAsyncProcess()
            return // Do nothing
        }

    }
    
    func completePurchase(title:String, message:String, error:Error?){
        self.stopAsyncProcess()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            (alert) in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            }
        })
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFailToLoadWithError error: Error) {
        print("Failed to load with error -\(error.localizedDescription)")
        presentUIAlert(sender: self, title: "Error loading", message: "Please try again"){
            self.dismiss(animated: true, completion: nil )
        }
    }
    
}
