//
//  HistoryVC.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase


class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var history:[String:TimeInterval] = [:] // barkey and date
    var barHistory:[Bar] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userRenewDateLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var userMembershipLabel: UIButton!
    
    @IBOutlet weak var moneySavedLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
       

    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func updateUI(){
        self.creditsLabel.text = "\(currentUser.credits!)"
        self.userMembershipLabel.setTitle(currentUser.membership, for: .normal)
        self.userRenewDateLabel.text = getDateStringFromTimeStamp(date: currentUser.currentPeriodEnd)
        let drinksUsed = currentUser.barsUsed.count
        self.moneySavedLabel.text = "$\(drinksUsed * 10).00" // Update with actual prices??
        if let image = currentUser.usersImage {
            self.userImageView.image = image
        }
        self.userNameLabel.text = currentUser.name
        DataService.ds.REF_USER_CURRENT.child(userDataTypes.barsUsed).observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let historyData = snapshot.value as? Dictionary<String,TimeInterval>{
                print(historyData)
                self.history = historyData
            }
        })
        DataService.ds.REF_BARS.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("CHUCK: SNAP - \(snap)")
                    let key = snap.key
                    if self.history.keys.contains(key){
                        if let barData = snap.value as? Dictionary<String, AnyObject>{
                            let newBar = Bar(barKey: snap.key, dataDict: barData)
                            newBar.getImage(){
                                self.barHistory.append(newBar)
                                //sort bars by date of use
                                self.barHistory.sort(by: { (bar1, bar2) -> Bool in
                                    return self.history[bar1.key]! > self.history[bar2.key]!
                                })
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
        })
    }
    //MARK: Tableview Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barHistory.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as! HistoryTableViewCell
        let bar = barHistory[indexPath.row]
        let date = history[bar.key]
        cell.barImageView.image = bar.img
        cell.barNameLabel.text = bar.barName
        cell.barStreetLabel.text = bar.locationStreet
        cell.dateLabel.text = getDateStringFromTimeStamp(date: date!)
        return cell
    }
}
