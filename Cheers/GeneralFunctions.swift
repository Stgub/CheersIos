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

class GeneralFunctions:NSObject{
    //MARK: UI Functions
    static func updateUserBanner(controller: UIViewController, nameL:UILabel,
                                 creditsL:UILabel,
                                 membershipB:UIButton,
                                 renewDateL:UILabel,
                                 imgL:UIImageView)
    {
        nameL.text = currentUser.name
        creditsL.text = "\(currentUser.credits!)"
        membershipB.setTitle(currentUser.membership, for: .normal)
        renewDateL.text = getDateStringFromTimeStamp(date: currentUser.currentPeriodEnd)
        currentUser.getUserImg(returnBlock: { (image) in
            DispatchQueue.main.async {
            imgL.image = image
            }
        })
        //TODO: Figure out how to move membership button action to here
        //membershipB.addTarget(self, action: #selector(presentAccountVC(sender:)), for: .touchUpInside)
    }
    
    /**
     Performs a segue from whatever UIViewControlle3r to the Feed VC
     */

   static func presentBarFeedVC(sender: UIViewController){
        print("presentBarFeeedVC:")
        let storyboard = UIStoryboard(name: myStoryboards.main, bundle: Bundle.main)
        let navController = storyboard.instantiateViewController(withIdentifier: "MainNavController")
        let vc = storyboard.instantiateViewController(withIdentifier: "BarFeedVC")
        sender.present(navController, animated: true, completion: nil)
    
    }
    
    static func presentFirstLoginVC(sender:UIViewController){
        print("presentFirstLoginVC:")
        let storyboard = UIStoryboard(name: myStoryboards.logOrSignIn, bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "FirstLoginVC")
        sender.present(vc, animated: true, completion: nil)
    }
    
    static func presentAccountVC(sender:UIViewController){
        let storyboard = UIStoryboard(name: myStoryboards.main, bundle: Bundle.main)
        let navController = storyboard.instantiateViewController(withIdentifier: "MainNavController")
        let vc = storyboard.instantiateViewController(withIdentifier: "AccountVC")
        //sender.present(vc, animated: true, completion: nil)
        navController.addChildViewController(vc)
        sender.present(navController, animated: true, completion: nil)
    }
    
    static func presentSignUpBarIntialVC(sender:UIViewController){
        let storyboard = UIStoryboard(name: myStoryboards.addBarFlow, bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpBarIntialVC")
        sender.present(vc, animated: true, completion: nil)
    }
    
}


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





func getDateStringFromTimeStamp(date: TimeInterval)-> String{
    let monthDayFormatter = DateFormatter()
    monthDayFormatter.dateFormat = "MM/dd"
    let dateString = monthDayFormatter.string(from: Date(timeIntervalSince1970: date))
    return dateString
}

/**
 Used to update the timer labels
 *@Return: time between drinks or the time now if there are no bars used  */
func timeLeftBetweenDrinks()->TimeInterval{
    let timeNow = NSDate().timeIntervalSince1970
    if let lastDrinkTime = currentUser.barsUsed.values.max() {
        return TIME_BETWEEN_DRINKS - (timeNow - lastDrinkTime)
    } else {
        return -1
    }
}

func timeStringFromIntervael(timeInterval:TimeInterval)->String{
    let hrs = Int(timeInterval/(60*60))
    let mins = Int(timeInterval .truncatingRemainder(dividingBy: 60*60) / 60 )
    var minsStr = "\(mins)"
    if mins < 10 {
        minsStr = "0\(mins)"
    }
    return "\(hrs):\(minsStr)"
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
