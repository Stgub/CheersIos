//
//  textViewRoundCorner.swift
//  Cheers
//
//  Created by Steven Graf on 3/10/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class textViewRoundCorner: UITextView {
    
    override func awakeFromNib() {
        layer.cornerRadius = 10
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
