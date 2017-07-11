//
//  RedeemSuccessVC.swift
//  Cheers
//
//  Created by Charles Fayal on 6/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class RedeemSuccessVC: UIViewController {

    var timer = Timer()
    var countdown = 30
    @IBOutlet weak var timeLabel: UILabel!
    @IBAction func okayBtnTapped(_ sender: Any) {
        GeneralFunctions.presentBarFeedVC(sender: self)
    }
    override func viewWillAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }

    func updateTimer(){
        countdown -= 1
        if countdown <= 0 {
            self.dismiss(animated: true, completion: nil)
        }
        timeLabel.text = String(countdown)
    }
    override func viewDidDisappear(_ animated: Bool) {
        countdown = 30
        timer.invalidate()
    }
}
