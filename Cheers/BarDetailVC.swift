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
    @IBAction func redeemDrinkBtnTapped(_ sender: Any) {
        print("CHUCK: User redeemed bar -\(bar.barName)")
        let dateStamp = NSDate().timeIntervalSince1970
        DataService.ds.REF_USER_CURRENT.child(userDataTypes.barsUsed).child(bar.key).setValue(dateStamp){
            (error, ref) in
            if error != nil {
                print("Chuck: Error redeeming -\(error)")
            } else {
                print("Successfully redeemed")
                currentUser.usedBar(barId: self.bar.key, currentDate:dateStamp)
                self.bar.hasBeenUsed = true
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if currentUser.credits <= 0 {
            redeemDrinkBtn.setTitle("Upgrade to recieve more credits!", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = false
        } else if let barUsed = bar.hasBeenUsed{
            if barUsed {
                let dateUsed = currentUser.barsUsed[bar.key]
                let dateAvailable = dateUsed! + 30 * 24 * 60 * 60
                if dateAvailable > NSDate().timeIntervalSince1970 {
                    redeemDrinkBtn.setTitle("Redeemed, available again: \(getDateStringFromTimeStamp(date: dateAvailable))", for: .normal)
                    redeemDrinkBtn.isUserInteractionEnabled = false
                } else{
                    redeemDrinkBtn.setTitle("Have your server tap to redeem", for: .normal)
                    
                    redeemDrinkBtn.isUserInteractionEnabled = true
                }
            }
        } else {
            redeemDrinkBtn.setTitle("Have your server tap to redeem", for: .normal)

            redeemDrinkBtn.isUserInteractionEnabled = true

        }

    }
    


}
