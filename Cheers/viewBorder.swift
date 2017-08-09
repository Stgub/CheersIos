//
//  viewBorder.swift
//  Cheers
//
//  Created by Steven Graf on 8/8/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class viewBorder: UIView {

    override func awakeFromNib() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }

}
