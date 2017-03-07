//
//  RoundedImageCorner.swift
//  Cheers
//
//  Created by Steven Graf on 3/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class RoundedImageCorner: UIImageView {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        clipsToBounds = true
    }

}
