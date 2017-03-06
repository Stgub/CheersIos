//
//  MembershipVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/5/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class MembershipVC: UIViewController {

    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upgradeBtnTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toPaymentVCSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
