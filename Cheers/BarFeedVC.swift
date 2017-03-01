//
//  ViewController.swift
//  Cheers
//
//  Created by Steven Graf on 2/26/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase

var userImage:UIImage!
class BarFeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    
    var bars:[Bar] = []
    var selectedBar:Bar!
    override func viewDidLoad() {
        super.viewDidLoad()
 
        userImageView.image = userImage
        DataService.ds.REF_BARS.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    print("CHUCK: SNAP - \(snap)")
                    let newBar = Bar()
                    
                    if let barData = snap.value as? Dictionary<String, AnyObject>{
                        let barName = snap.key
                        newBar.name = barName
                        if let location = barData[Bar.dataTypes.location] as? String{
                            print("Location = \(location)")
                            newBar.location = location
                            self.tableView.reloadData()
                            
                        }
                        
                        if let imgUrl = barData[Bar.dataTypes.imgUrl] as? String{
                            print("Image URL = \(imgUrl)")
                            let ref = FIRStorage.storage().reference(forURL: imgUrl)
                            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                                if error != nil {
                                    print("Chuck: Error downloading img -\(error)")
                                    
                                } else {
                                    print("Chuck: Img downloaded from Firebase storage")
                                    if let imgData = data {
                                        if let img = UIImage(data: imgData) {
                                            newBar.img = img
                                            self.bars.append(newBar)
                                            self.tableView.reloadData()
                                        } else { print("Could not load image from data")}
                                    }
                                }
                            })

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
        if let barName = bar.name {
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
            if let bar = selectedBar {
                destVC.bar = selectedBar
            }
        default:
            print("Segue to default controller type")
        }
    }


}

