//
//  BarTableViewCell.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class BarTableViewCell: UITableViewCell {
    var bar:Bar!
    //var delegate:BarFeedVC!
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    
    @IBOutlet weak var barImageView: UIImageView!
    @IBOutlet weak var barStreetLabel: UILabel!
    
    @IBOutlet weak var barAreaLabel: UILabel!
    @IBOutlet weak var oneFreeDrinkIcon: UIImageView!
    @IBOutlet weak var freeAppIcon: UIImageView!
    @IBOutlet weak var genericDealIcon: UIImageView!
    @IBOutlet weak var wineDealIcon: RoundedImageCorner!
    /*
    @IBOutlet weak var freeDrinkBtn: UIButton!
    
    @IBAction func redeemBtnTapped(_ sender: Any) {
        print("Chuck: Tap redeem drink for -\(bar.barName)")
        delegate.tappedBar(forBar:bar)
        
    }
 */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
