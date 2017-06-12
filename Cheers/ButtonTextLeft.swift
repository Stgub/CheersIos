//
//  ButtonTextLeft.swift
//  Cheers
//
//  Created by Steven Graf on 6/9/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class ButtonTextLeft: UIButton {

    override func awakeFromNib() {
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        
    }
    
}
