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
class BarFeedVC: BaseMenuVC, UITableViewDataSource, UITableViewDelegate,BarServiceObserver {

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
    private var selectedBar:Bar!
    private var drinkTimer = Timer()

    @IBOutlet weak var leftMenuButton: UIButton!
    //UserBanner stuff
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var membershipBtn: UIButton!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var renewDateLabel: UILabel!
    @IBOutlet weak var drinkTimeLeft: UILabel!
    
    @IBOutlet weak var dayBtnOutlet: UIButton!
    
    @IBAction func dayBtnTapped(_ sender: Any) {
        self.dayLookedAtNum = dayLookedAtNum + 1
    }
    @IBAction func membershipBtnTapped(_ sender: Any) {
        GeneralFunctions.presentAccountVC(sender: self)
    }


    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        drinkTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateDrinkTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        drinkTimer.invalidate()
        BarService.sharedService.removeObserver(observer: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachMenuButton(menuButton: leftMenuButton)
        UserService.shareService.updateUser() // used to make sure the users subscription is correct
        _dayLookedAtNum = Date().dayNumberOfWeek()!
        dayLookedAtNum = _dayLookedAtNum
        BarService.sharedService.addObserver(observer: self)
        BarService.sharedService.getBars()
    }
    
    func updatedBars(){
        self.tableView.reloadData()
    }
    
    private func updateUI(){
        self.updateDrinkTimer()
        GeneralFunctions.updateUserBanner(controller: self, nameL: userNameLabel,
                                          creditsL: creditsLabel,
                                          membershipB: membershipBtn,
                                          renewDateL: renewDateLabel,
                                          imgL: userImageView)
        
        tableView.reloadData()
    }
    
    @objc private func updateDrinkTimer(){
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
    private var bars:[String] = []
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day =  weekDays(rawValue: _dayLookedAtNum)!
        bars = BarService.sharedService.getBars(forDay:day).sorted()
        return bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell (withIdentifier: "BarTableViewCell") as! BarTableViewCell
        cell.delegate = self // used to call back when a bar is tapped
        let barString = bars[indexPath.row]
        guard let bar = BarService.sharedService.getBar(id:barString) else {
            return cell
        }
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
        
        bar.setImage(imageView: cell.barImageView!)
        
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

