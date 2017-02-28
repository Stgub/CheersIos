//
//  Shadow&RoundBtn.swift
//  Cheers
//
//  Created by Steven Graf on 2/26/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class Shadow_RoundBtn: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.height / 2
    }

}
