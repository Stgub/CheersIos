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

    @IBOutlet weak var userImageView: UIImageView!
    
    var bars:[Bar] = []
    var selectedBar:Bar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUserInfo { 
            if let user = currentUser{
                user.getUserImg(returnBlock: { (image) in
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                    }
                
                })
            } else { print( "CHUCK: No current user") }
        }

        DataService.ds.REF_BARS.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("CHUCK: SNAP - \(snap)")
                    if let barData = snap.value as? Dictionary<String, AnyObject>{
                        let newBar = Bar(barKey: snap.key, dataDict: barData)
                        newBar.getImage(){
                            self.bars.append(newBar)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    //MARK: Table View functions
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell (withIdentifier: "BarTableViewCell") as! BarTableViewCell
        let bar = bars[indexPath.row]
        cell.bar = bar
        if let barName = bar.barName {
            cell.barNameLabel.text = barName
        }
        if let barLocation = bar.location {
            cell.barStreetLabel.text = barLocation
        }
        if let barImage = bar.img {
            cell.barImageView.image = barImage
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? BarTableViewCell {
            selectedBar = cell.bar
            self.performSegue(withIdentifier: "toBarDetailSegue", sender: self)
        }
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

