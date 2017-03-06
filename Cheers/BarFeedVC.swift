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
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var membershipLabel: UIButton!
    @IBOutlet weak var creditsLabel: UILabel!
    
    @IBAction func membershipBtnTapped(_ sender: Any) {
        presentMembershipVC(sender:self)
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        if let user = currentUser{
            self.creditsLabel.text = "Credits: \(user.credits!)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUserInfo { 
            if let user = currentUser{
                self.userNameLabel.text = user.name
                self.creditsLabel.text = "Credits: \(user.credits!)"
                self.membershipLabel.setTitle(user.membership, for: .normal)
                user.getUserImg(returnBlock: { (image) in
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                    }
                
                })
                guard let barsUsed = user.barsUsed else {
                    print("Chuck: Bars used not there")
                    return
                }
                //Get bars

                DataService.ds.REF_BARS.observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshots {
                            print("CHUCK: SNAP - \(snap)")
                            if let barData = snap.value as? Dictionary<String, AnyObject>{
                                let newBar = Bar(barKey: snap.key, dataDict: barData)
                                if barsUsed.keys.contains(newBar.key){
                                    newBar.hasBeenUsed = true
                                } else {
                                    newBar.hasBeenUsed = false
                                }
                                newBar.getImage(){
                                    self.bars.append(newBar)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                })
                
                
            } else { print( "CHUCK: No current user") }
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

