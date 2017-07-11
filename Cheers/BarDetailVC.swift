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
    override func viewWillDisappear(_ animated: Bool) {
        updateTimer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    func verifyPhone(){
        self.performSegue(withIdentifier: "verifyPhoneSegue", sender: self)
    }
    
    func goToAccount(){
        GeneralFunctions.presentAccountVC(sender: self)
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
                self.performSegue(withIdentifier: "drinkRedeemedSegue", sender: self)
            }
        }
    }
    
    private var updateTimer = Timer()
    func updateTimeLabel(){
        if timeLeftBetweenDrinks() < 0 {
            updateTimer.invalidate()
            updateUI()
        } else {
            redeemDrinkBtn.setTitle("\(timeStringFromInterval(timeInterval: timeLeftBetweenDrinks()))", for: .normal)
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
        
        //remove actions linked to button, if adding more there's a better way
        redeemDrinkBtn.removeTarget(nil, action: nil, for: .touchUpInside)
        updateTimer.invalidate()
        if currentUser.phoneNumber == nil && !ConfigUtil.inTesting{
            redeemDrinkBtn.setTitle("Verify Phone", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = true
            redeemDrinkBtn.addTarget(self, action: #selector(self.verifyPhone), for: .touchUpInside)
        } else if currentUser.credits <= 0 {
            //User has no credits left to buy drins
            redeemDrinkBtn.setTitle("Upgrade to recieve more credits!", for: .normal)
            redeemDrinkBtn.isUserInteractionEnabled = false
            redeemDrinkBtn.addTarget(self, action: #selector(self.goToAccount),for: .touchUpInside)
        } else if !BarUtil.isBarAvailable(bar:bar) {
            //Bar has been used and is not available yet
            self.redeemDrinkBtn.setTitle("Drink Redeemed!", for: .normal) //, available again: \(getDateStringFromTimeStamp(date: dateAvailable))"
            self.redeemDrinkBtn.isUserInteractionEnabled = false
        } else if timeLeftBetweenDrinks() > 0{
            //User has recently used a drink and must wait for TIME_BETWEEN_DRINKS
            redeemDrinkBtn.isUserInteractionEnabled = false
            updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimeLabel), userInfo: nil, repeats: true)
            
        } else{
            guard let dayNum = Date().dayNumberOfWeek(), let dayStr:String = weekDays(rawValue:dayNum)?.toString, let isAvailable:Bool = bar.availableDays[dayStr], isAvailable else {
                self.redeemDrinkBtn.setTitle("Bar is not available today", for: .normal)
                self.redeemDrinkBtn.isUserInteractionEnabled = false
                return
            }
            if isAvailable {
                self.redeemDrinkBtn.setTitle("Have your server tap to redeem", for: .normal)
                self.redeemDrinkBtn.isUserInteractionEnabled = true
                self.redeemDrinkBtn.addTarget(self, action: #selector(self.redeemDrink), for: .touchUpInside)
            }
        

        }
    }
    


}
