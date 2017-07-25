//
//  Protocols.swift
//  Cheers
//
//  Created by Charles Fayal on 2/28/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import UIKit

protocol LoginController {
    func loginComplete()
    func loginFailed(title:String,message:String)
}
protocol hasBarVar {
    var bar:Bar! {get set}
}
protocol  hasDataDict {
    var dataDict:[String:Any]{get set}
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
   /* func weekDayforNum(num:Int)->String{
        switch(num){
        case 1:
            return weekDays.sunday.rawValue
        case 2:
            return weekDays.monday.rawValue
        case 3:
            return weekDays.tuesday.rawValue
        case 4:
            return weekDays.wednesday.rawValue
        case 5:
            return weekDays.thursday.rawValue
        case 6:
            return weekDays.friday.rawValue
        case 7:
            return weekDays.saturday.rawValue
        default:
            return "Error"
        }
    }*/
}



struct AsyncUIHandler{
    var vc: UIViewController
    var view: UIView
    var asyncInProgress: Bool = false {
        didSet {
            if asyncInProgress {
                self.view.isUserInteractionEnabled = false
                self.activityIndicator.startAnimating()
                self.activityIndicator.alpha = 1
            } else {
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0
            }
        }
    }
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    init(vc: UIViewController){
        self.vc = vc
        self.view = vc.view
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.alpha = 0
        self.activityIndicator.center = self.view.center
    }

}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


