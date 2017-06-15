//
//  ViewController.swift
//  Cheers
//
//  Created by Steven Graf on 2/26/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase

var currentUser:User!
class BarFeedVC: BaseMenuVC, UITableViewDataSource, UITableViewDelegate {

    private var _dayLookedAtNum:Int!
    private var dayLookedAtNum:Int! {
        set(newVal){
            self._dayLookedAtNum = newVal % 7
            if _dayLookedAtNum <= 0 { _dayLookedAtNum = 7}
            if _dayLookedAtNum == Date().dayNumberOfWeek() {
                self.dayBtnOutlet.setTitle("Today", for: .normal) //

            } else {
                self.dayBtnOutlet.setTitle(weekDays(rawValue:_dayLookedAtNum)!.toString, for: .normal) //

            }
            self.tableView.reloadData()
        }
        get{
            return self._dayLookedAtNum
        }
    }
    private var bars:[String:Bar] = [:]
    private var selectedBar:Bar!
    private var drinkTimer = Timer()
    private var barPerDay:Dictionary<String,[String]> = [:]
    

    @IBOutlet weak var leftMenuButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var membershipLabel: UIButton!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var renewDateLabel: UILabel!
    @IBOutlet weak var drinkTimeLeft: UILabel!
    
    @IBOutlet weak var dayBtnOutlet: UIButton!
    
    @IBAction func dayBtnTapped(_ sender: Any) {
        self.dayLookedAtNum = dayLookedAtNum + 1
    }


    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        drinkTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateDrinkTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        drinkTimer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachMenuButton(menuButton: leftMenuButton)
        StripeAPIClient.sharedClient.updateCustomer() // used to make sure the users subscription is correct
        _dayLookedAtNum = Date().dayNumberOfWeek()!
        dayLookedAtNum = _dayLookedAtNum
    }
    
    func updateUI(){
        self.updateDrinkTimer()
        self.userNameLabel.text = currentUser.name
        self.creditsLabel.text = "\(currentUser.credits!)"
        self.membershipLabel.setTitle(currentUser.membership, for: .normal)
        self.renewDateLabel.text = getDateStringFromTimeStamp(date: currentUser.currentPeriodEnd)
        currentUser.getUserImg(returnBlock: { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
            
        })
        let barsUsed = currentUser.barsUsed
        MyFireBaseAPIClient.sharedClient.getBars(){
            (returnedBars) in
            print("Backend API returned bars")
            for newBar in returnedBars{
                var bar:Bar
                
                if self.bars[newBar.key] == nil {
                    bar = newBar
                    self.bars[bar.key] = bar
                    bar.getImage(){
                        print("Appending \(bar.barName) to tableview")
                        self.tableView.reloadData()
                    }
                } else {
                    bar = self.bars[newBar.key]!
                }
                let barDays = bar.availableDays
                print("*********\(bar.barName!) Added to Bar Feed#####")
                //print(barDays)
                for i in 1...7 {
                    let dayString = weekDays(rawValue:i)!.toString
                    if let dayBool = barDays[dayString]{
                        if dayBool{
                            if self.barPerDay[dayString] == nil {
                                self.barPerDay[dayString] = [bar.key]
                            } else {
                                if !self.barPerDay[dayString]!.contains(bar.key){
                                    self.barPerDay[dayString]!.append(bar.key)
                                }
                            }
                        }
                    }
                }
    
                if barsUsed.keys.contains(bar.key){
                    bar.hasBeenUsed = true
                } else {
                    bar.hasBeenUsed = false
                }

            }
        
        }
        tableView.reloadData()
    }
    
    func updateDrinkTimer(){
        let timeLeft = timeLeftBetweenDrinks()
        if timeLeft < 0 {
            drinkTimer.invalidate()
            drinkTimeLeft.isHidden = true
        } else {
            drinkTimeLeft.isHidden = false
            drinkTimeLeft.text = timeStringFromIntervael(timeInterval: timeLeft)
        }
    }
    /**
     Called from BarTableViewCell
    */
    func tappedBar(forBar:Bar){
        selectedBar = forBar
        self.performSegue(withIdentifier: "toBarDetailSegue", sender: self)
    }
    //MARK: Table View functions
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let barArray = barPerDay[weekDays(rawValue:_dayLookedAtNum)!.toString] else {
            return 0
        }
        print("barArray------\(barArray)")
        return barArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell (withIdentifier: "BarTableViewCell") as! BarTableViewCell
        cell.delegate = self // used to call back when a bar is tapped 
        let barString = barPerDay[weekDays(rawValue:_dayLookedAtNum)!.toString]![indexPath.row]
        let bar = bars[barString]!
        cell.bar = bar
    
        if let barName = bar.barName {
            cell.barNameLabel.text = barName
        }
        if let barStreet = bar.locationStreet {
            cell.barStreetLabel.text = barStreet
        } else {
            cell.barStreetLabel.text = "No address"
        }
        var locationString = ""
        if let barCity = bar.locationCity {
            locationString += barCity
        }
        if let barState  = bar.locationState{
            locationString += ", \(barState)"
        }
        if let barZipcode = bar.locationZipCode{
             locationString += " \(barZipcode)"
        }
        cell.barAreaLabel.text = locationString
        
        if let barImage = bar.img {
            cell.barImageView.image = barImage
        }
        if let barUsed = bar.hasBeenUsed{
            if barUsed{
                cell.freeDrinkBtn.setTitle("Drink Used", for: .normal)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BarTableViewCell
       tappedBar(forBar: cell.bar)
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        switch(dest){
        case is hasBarVar:
            var destVC = dest as! hasBarVar
            if let selBar = selectedBar {
                destVC.bar = selBar
            }
        default:
            print("Segue to default controller type")
        }
    }

}

