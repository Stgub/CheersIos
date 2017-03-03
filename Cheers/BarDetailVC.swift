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
        dateFormater.dateFormat = "MM-dd-yyyy"
        let currentDateString = dateFormater.string(from: currentDate)
        print("CHUCK: User redeemed bar -\(bar.barName)")
        DataService.ds.REF_USER_CURRENT.child(userDataTypes.barsUsed).child(bar.key).setValue(currentDateString) {
            (error, ref) in
            if error != nil {
                print("Chuck: Error redeeming -\(error)")
            } else {
                print("Successfully redeemed")
                currentUser.barsUsed[self.bar.key] = currentDateString
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
        if let barStreet = bar.location{
            barStreetLabel.text = barStreet
        }
        if let barUsed = bar.hasBeenUsed{
            if barUsed {
                redeemDrinkBtn.setTitle("Already redeemed drink", for: .normal)
                redeemDrinkBtn.isUserInteractionEnabled = false
            }
        }
        // Do any additional setup after loading the view.
    }
    


}
