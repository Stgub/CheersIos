//
//  AccountVC.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class AccountVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func logOutBtnTapped(_ sender: Any) {
        print("Log out btn tapped")
        UserService.shareService.signOut()
        presentFirstLoginVC(sender:self)

        
    }
    // Contact Us Buttons
    
    @IBAction func reccomendTapped(_ sender: Any) {
        let reccomendDesc = "Want your favorite bar to be part of the Drink Club? Send us an email with the name of your bar!"
        performSegue(withIdentifier: "toContactUsVC", sender: reccomendDesc)
    }
    @IBAction func feedbackTapped(_ sender: Any) {
        let feedbackDesc = "We're just getting started here, and any feedback you have would be greatly appreciated! Please send your thoughts here:"
        self.performSegue(withIdentifier: "toContactUsVC", sender: feedbackDesc)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? contactUsVC {
            
            if let contactBtnDesc = sender as? String {
                destinationVC.selectedContact = contactBtnDesc
            }
        }
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
