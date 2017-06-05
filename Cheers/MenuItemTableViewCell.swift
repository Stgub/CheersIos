//
//  MenuItemTableViewCell.swift
//  Cheers
//
//  Created by Charles Fayal on 6/4/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    var menuItem:MenuItem!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setMenuItem(menuItem:MenuItem){
        self.menuItem = menuItem
        self.titleLabel.text = menuItem.title
    }

}
