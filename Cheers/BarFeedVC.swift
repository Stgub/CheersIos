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
class BarFeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var bars:[Bar] = []
    var selectedBar:Bar!
    fileprivate var drinkTimer = Timer()
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var membershipLabel: UIButton!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var renewDateLabel: UILabel!
    @IBOutlet weak var drinkTimeLeft: UILabel!
    
    @IBAction func membershipBtnTapped(_ sender: Any) {
        presentMembershipVC(sender:self)
    }

    override func viewDidAppear(_ animated: Bool) {
        if timeLeftBetweenDrinks() > 0 {
            drinkTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.updateDrinkTimer), userInfo: nil, repeats: true)
            drinkTimer.fire()
        } else {
            drinkTimeLeft.isHidden = true
        }
            
        tableView.reloadData()
        if let user = currentUser{
            self.creditsLabel.text = "Credits: \(user.credits!)"
            self.membershipLabel.setTitle(currentUser.membership, for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MyFireBaseAPIClient.sharedClient.startObservingDatabase()
        
        self.userNameLabel.text = currentUser.name
        self.creditsLabel.text = "Credits: \(currentUser.credits!)"
        self.membershipLabel.setTitle(currentUser.membership, for: .normal)
        self.renewDateLabel.text = getDateStringFromTimeStamp(date: currentUser.currentPeriodEnd)
        currentUser.getUserImg(returnBlock: { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        
        })
        guard let barsUsed = currentUser.barsUsed else {
            print("Backend: Bars used not there")
            return
        }
        //Get bars
        
        MyFireBaseAPIClient.sharedClient.getBars(){
            (returnedBars) in
            print("Backend API returned bars")
            for bar in returnedBars{
                if barsUsed.keys.contains(bar.key){
                    bar.hasBeenUsed = true
                } else {
                    bar.hasBeenUsed = false
                }
                bar.getImage(){
                    print("Appending \(bar.barName) to tableview")
                    self.bars.append(bar)
                    self.tableView.reloadData()
                }
            }
        }
        
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
        return bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell (withIdentifier: "BarTableViewCell") as! BarTableViewCell
        cell.delegate = self
        let bar = bars[indexPath.row]
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
    
    func setUserImage(){
        if let userImage = currentUser.usersImage {
            print("Have current users image")
            userImageView.image = userImage
        } else {
            print("Have not downloaded current users image")
            currentUser.getUserImg(){
                userImage in
                self.userImageView.image = userImage
            }
        }
    }


 

}

