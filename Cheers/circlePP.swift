//
//  circlePP.swift
//  Cheers
//
//  Created by Steven Graf on 4/13/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class circlePP: UIImageView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 28
        clipsToBounds = true
    }

}
