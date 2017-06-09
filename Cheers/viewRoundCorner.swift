//
//  viewRoundCorner.swift
//  Cheers
//
//  Created by Steven Graf on 6/9/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class viewRoundCorner: UIView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        clipsToBounds = true
    }

}
