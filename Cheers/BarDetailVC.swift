//
//  BarDetailVC.swift
//  Cheers
//
//  Created by Charles Fayal on 2/28/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class BarDetailVC: UIViewController, hasBarVar {
    var bar:Bar!
    
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var barImageView: UIImageView!
    @IBOutlet weak var barStreetLabel: UILabel!
    @IBOutlet weak var barDescriptLabel: UILabel!
    @IBOutlet weak var barPhoneNumLabel: UILabel!
    @IBOutlet weak var barDrinksLabel: UILabel!
    @IBOutlet weak var redeemDrinkBtn: UIButton!
    
    @IBOutlet weak var barHoursTitleLabel: UILabel!
    @IBOutlet weak var barHoursLabel: UILabel!
    @IBOutlet weak var barDealsLabel: UILabel!
    
        
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var swipeGesture = UISwipeGestureRecognizer(target: self , action: #selector(self.backBtnTapped(_:)))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
    }
    func verifyPhone(){
        self.performSegue(withIdentifier: "verifyPhoneSegue", sender: self)
    }
    
    func goToAccount(){
        GeneralFunctions.presentAccountVC(sender: self)
    }
    func redeemDrink(){
        print("BarDetailVC: User redeemed perk -\(bar.barName)")
        UserService.sharedService.redeemedDrink(bar:bar){
            error in
            if error != nil {
                presentUIAlert(sender: self, title: "Error Redeeming Perk", message: (error?.localizedDescription)!)
            } else {
                self.performSegue(withIdentifier: "perkRedeemedSegue", sender: self)
            }
        }
    }

    func updateUI(){
        if let barName = bar.barName{
            barNameLabel.text = barName
        }
        if let barImage = bar.img{
            barImageView.image = barImage
        }
        if let barStreet = bar.locationStreet{
            barStreetLabel.text = barStreet
        }
        if let barPhoneNum = bar.phoneNumber{
            barPhoneNumLabel.text = barPhoneNum
        }
        if let hoursOpen = bar.hoursOpen{
            barHoursLabel.text = BarUtil.getHoursParagraph(hoursOpen: hoursOpen)
        } else {
            barHoursLabel.isHidden = true
            barHoursTitleLabel.isHidden = true
        }
        if let barDescript = bar.description{
            barDescriptLabel.text = barDescript
        }
        var dealsText = ""
        for deal in bar.deals.keys {
            switch(deal){
                case dealTypes.buyOneGetOne:
                    dealsText += "\u{2022}Buy one get one beer/cocktail\n"
                case dealTypes.freeApp:
                    dealsText += "\u{2022}Free appetizer with Entree\n"
                case dealTypes.halfOffBottle:
                    dealsText += "\u{2022}Half off bottle of wine\n"
                case dealTypes.oneFreeDrink:
                    dealsText += "\u{2022}One free drink\n"
                default:
                    dealsText += "\u{2022}" + deal + "\n"
            }
        }
        barDealsLabel.text = dealsText
        
        redeemDrinkBtn.removeTarget(nil, action: nil, for: .touchUpInside)

        guard let currentUser = UserService.sharedService.getCurrentUser() else {
            print("ERROR: No current user")
            return
        }
        redeemDrinkBtn.removeTarget(nil, action: nil, for: .touchUpInside)

        if currentUser.phoneNumber == nil && ConfigUtil.verifyPhoneOn{
            redeemDrinkBtn.setTitle("Verify Phone", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = true
            redeemDrinkBtn.addTarget(self, action: #selector(self.verifyPhone), for: .touchUpInside)
        } else if currentUser.credits <= 0 {
            //User has no credits left to buy drins
            redeemDrinkBtn.setTitle("Upgrade to recieve more credits!", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = true
            redeemDrinkBtn.addTarget(self, action: #selector(self.goToAccount),for: .touchUpInside)
        } else if !BarUtil.isBarAvailable(bar:bar) {
            //Bar has been used and is not available yet
            self.redeemDrinkBtn.setTitle("Perk Redeemed!", for: .normal)
            self.redeemDrinkBtn.isUserInteractionEnabled = false
        } else{
            guard let dayNum = Date().dayNumberOfWeek(), let dayStr:String = weekDays(rawValue:dayNum)?.toString, let isAvailable:Bool = bar.availableDays[dayStr], isAvailable else {
                self.redeemDrinkBtn.setTitle("Bar is not available today", for: .normal)
                self.redeemDrinkBtn.isUserInteractionEnabled = false
                return
            }
            if isAvailable {
                print("Bar available for redepmtion")
                self.redeemDrinkBtn.setTitle("Have your server tap to redeem", for: .normal)
                self.redeemDrinkBtn.isUserInteractionEnabled = true
                self.redeemDrinkBtn.addTarget(self, action: #selector(self.redeemDrink), for: .touchUpInside)
            }
        

        }
    }
    


}
