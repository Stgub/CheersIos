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
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func redeemDrinkBtnTapped(_ sender: Any) {
        let currentDate = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let currentDateString = dateFormater.string(from: currentDate)
        print("CHUCK: User redeemed bar -\(bar.barName)")
        DataService.ds.REF_USER_CURRENT.child(userDataTypes.barsUsed).child(bar.key).setValue(currentDateString) {
            (error, ref) in
            if error != nil {
                print("Chuck: Error redeeming -\(error)")
            } else {
                print("Successfully redeemed")
                currentUser.usedBar(barId: self.bar.key, currentDate:currentDateString)
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
        if currentUser.credits <= 0 {
            redeemDrinkBtn.setTitle("Upgrade to recieve more credits!", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = false
        } else if let barUsed = bar.hasBeenUsed{
            if barUsed {
                let dateUsed = currentUser.barsUsed[bar.key]
                var date = getDateFromDateString(date:dateUsed!)
                date.addTimeInterval(60 * 60 * 24 * 30)
                if date.timeIntervalSinceNow > 0 {
                    redeemDrinkBtn.setTitle("Redeemed, available again: \(getStringFromDate(date: date))", for: .normal)
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
        // Do any additional setup after loading the view.
    }
    


}
