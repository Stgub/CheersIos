//
//  contactUsVC.swift
//  Cheers
//
//  Created by Steven Graf on 3/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class contactUsVC: UIViewController {

    @IBAction func backBtnTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet weak var contactDesc: UILabel!
    
    private var _selectedContact: String!
    
    var selectedContact: String {
        get {
            return _selectedContact
        } set {
            _selectedContact = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contactDesc.text = _selectedContact
        
    }
    
    //Send to email
    @IBAction func emailBtnTapped(_ sender: Any) {
        let email = "ContactTheDrinkClub@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
