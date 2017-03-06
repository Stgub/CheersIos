//
//  HistoryTableViewCell.swift
//  Cheers
//
//  Created by Charles Fayal on 3/3/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var barImageView: UIImageView!
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var barStreetLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
