//
//  GeneralFunctions.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import UIKit
//Simple UIalert function...
func presentUIAlert(sender: UIViewController, title:String, message:String){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(defaultAction)
    sender.present(alertController, animated: true, completion: nil)
    
}
/**
 Performs a segue from whatever UIViewController to the Feed VC
 */
func presentBarFeedVC(sender: UIViewController){
    let storyboard = UIStoryboard(name: myStoryboards.main, bundle: Bundle.main)
    let vc = storyboard.instantiateViewController(withIdentifier: "BarFeedVC")
    sender.present(vc, animated: true, completion: nil)
}
func presentFirstLoginVC(sender:UIViewController){
    let storyboard = UIStoryboard(name: myStoryboards.main, bundle: Bundle.main)
    let vc = storyboard.instantiateViewController(withIdentifier: "FirstLoginVC")
    sender.present(vc, animated: true, completion: nil)
}
