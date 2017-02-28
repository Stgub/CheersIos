//
//  ViewController.swift
//  Cheers
//
//  Created by Steven Graf on 2/26/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

var userImage:UIImage!
class BarFeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        userImageView.image = userImage
        
        
    }
    
    //MARK: Table View functions
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell (withIdentifier: "BarTableViewCell") as! BarTableViewCell
        return cell
    }

    


}

