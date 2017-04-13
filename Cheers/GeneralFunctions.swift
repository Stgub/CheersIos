//
//  GeneralFunctions.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import UIKit
import Firebase

//Simple UIalert function...
func presentUIAlert(sender: UIViewController, title:String, message:String, returnBlock: (()->Void)? = nil){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .default) { (action) in
        if returnBlock != nil {
            returnBlock!()
        }
    }
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
func presentMembershipVC(sender:UIViewController){
    let storyboard = UIStoryboard(name: myStoryboards.main, bundle: Bundle.main)
    let vc = storyboard.instantiateViewController(withIdentifier: "MembershipVC")
    sender.present(vc, animated: true, completion: nil)
}
func presentSignUpBarIntialVC(sender:UIViewController){
    let storyboard = UIStoryboard(name: myStoryboards.main, bundle: Bundle.main)
    let vc = storyboard.instantiateViewController(withIdentifier: "SignUpBarIntialVC")
    sender.present(vc, animated: true, completion: nil)
}


func getDateStringFromTimeStamp(date: TimeInterval)-> String{
    let monthDayFormatter = DateFormatter()
    monthDayFormatter.dateFormat = "MM/dd"
    let dateString = monthDayFormatter.string(from: Date(timeIntervalSince1970: date))
    return dateString
}
/*
func getStringFromDate(date:Date) -> String{
    
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "MM/dd/yyyy"
    let dateString = dateFormater.string(from: date)
    return dateString
}*/
/*
func getDateFromDateString(date:String) -> Date{
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "MM/dd/yyyy"
    let date = dateFormater.date(from: date)!
    return date
}
*/
