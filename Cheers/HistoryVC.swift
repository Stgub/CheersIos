//
//  HistoryVC.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase


class HistoryVC: BaseMenuVC, UITableViewDelegate, UITableViewDataSource {

    var barHistory:[Bar] = []
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userRenewDateLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var membershipBtn: UIButton!
    @IBOutlet weak var leftMenuButton: UIButton!
    @IBOutlet weak var moneySavedLabel: UILabel!
    
    @IBAction func membershipBtnTapped(_ sender: Any) {
        GeneralFunctions.presentAccountVC(sender: self)
    }
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        attachMenuButton(menuButton: leftMenuButton)
    }

 
    func updateUI(){
        GeneralFunctions.updateUserBanner(controller: self,
                                          nameL: userNameLabel,
                                          creditsL: creditsLabel,
                                          membershipB:membershipBtn,
                                          renewDateL: userRenewDateLabel,
                                          imgL: userImageView)
        
        guard let currentUser = UserService.sharedService.getCurrentUser() else {
            print("Error: no current user")
            return
        }
        let drinksUsed = currentUser.barsUsed.count
        self.moneySavedLabel.text = "$\(drinksUsed * 10).00" // Update with actual prices??
        
        
        //TODO move this to bar service
        DataService.ds.REF_BARS.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    print("CHUCK: SNAP - \(snap)")
                    let key = snap.key
                    if currentUser.barsUsed.keys.contains(key){
                        if let barData = snap.value as? Dictionary<String, AnyObject>{
                            let newBar = Bar(barKey: snap.key, dataDict: barData)
                            self.barHistory.append(newBar)
                            // sort bars based of date used
                            self.barHistory = self.barHistory.sorted(by: { (a, b) -> Bool in
                                guard let aDate = currentUser.barsUsed[a.key] else {
                                    return true
                                }
                                guard let bDate = currentUser.barsUsed[b.key] else {
                                    return true
                                }
                                return aDate > bDate
                            })
                            self.tableView.reloadData()
                            
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
        guard let currentUser = UserService.sharedService.getCurrentUser() else {
            print("Error: no current user")
            return cell
        }
        let date = currentUser.barsUsed[bar.key]
        bar.setImage(imageView: cell.barImageView)
        cell.barNameLabel.text = bar.barName
        cell.barStreetLabel.text = bar.locationStreet
        cell.dateLabel.text = getDateStringFromTimeStamp(date: date!)
        return cell
    }
}
