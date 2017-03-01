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

    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let barName = bar.name{
            barNameLabel.text = barName
        }
        if let barImage = bar.img{
            barImageView.image = barImage
        }
        if let barStreet = bar.location{
            barStreetLabel.text = barStreet
        }
        // Do any additional setup after loading the view.
    }
    


}
