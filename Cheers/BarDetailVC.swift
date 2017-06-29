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
    @IBOutlet weak var barHoursLabel: UILabel!
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    func verifyPhone(){
        self.performSegue(withIdentifier: "verifyPhoneSegue", sender: self)
    }
    
    func redeemDrink(){
        print("CHUCK: User redeemed bar -\(bar.barName)")
        let dateStamp = NSDate().timeIntervalSince1970
        DataService.ds.REF_USER_CURRENT.child(userDataTypes.barsUsed).child(bar.key).setValue(dateStamp){
            (error, ref) in
            if error != nil {
                print("Chuck: Error redeeming -\(String(describing: error))")
            } else {
                print("Successfully redeemed")
                currentUser.usedBar(barId: self.bar.key, currentDate:dateStamp)
                self.bar.hasBeenUsed = true
                self.performSegue(withIdentifier: "drinkRedeemedSegue", sender: self)
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
        if let barHours = bar.hoursTime{
            if let barAmPm = bar.hoursAmPm{
                barHoursLabel.text = Bar.getHoursParagraph(hoursDict: barHours, amPmDict: barAmPm)
            }
        }
        if let barDescript = bar.description{
            barDescriptLabel.text = barDescript
        }
        //Check the next availability of bar
        var dateAvailable: TimeInterval = 0
        if bar.hasBeenUsed ?? false {
            let dateUsed = currentUser.barsUsed[bar.key]
            dateAvailable = dateUsed! + 30 * 24 * 60 * 60 // one month
        }
        //remove actions linked to button, if adding more there's a better way
        redeemDrinkBtn.removeTarget(self, action: #selector(verifyPhone), for: .touchUpInside)
        redeemDrinkBtn.removeTarget(self, action: #selector(redeemDrink), for: .touchUpInside)

        if currentUser.phoneNumber == nil {
            redeemDrinkBtn.setTitle("Verify Phone", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = true
            redeemDrinkBtn.addTarget(self, action: #selector(self.verifyPhone), for: .touchUpInside)

        } else if currentUser.credits <= 0 {
            //User has no credits left to buy drins
            redeemDrinkBtn.setTitle("Upgrade to recieve more credits!", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = false
        } else if dateAvailable != 0  &&  dateAvailable > NSDate().timeIntervalSince1970{
            //Bar has been used and is not available yet
            redeemDrinkBtn.setTitle("Redeemed, available again: \(getDateStringFromTimeStamp(date: dateAvailable))", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = false
        } else if timeLeftBetweenDrinks() > 0{
            //User has recently used a drink and must wait for TIME_BETWEEN_DRINKS
            redeemDrinkBtn.isUserInteractionEnabled = false
            redeemDrinkBtn.setTitle("\(timeStringFromIntervael(timeInterval: timeLeftBetweenDrinks())) left until another drink can be used", for: .normal)
        } else {
            //User is good to use drink
            redeemDrinkBtn.setTitle("Have your server tap to redeem", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = true
            redeemDrinkBtn.addTarget(self, action: #selector(self.redeemDrink), for: .touchUpInside)

        }
    }
    


}
