//
//  User.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import UIKit
import Firebase
var userImage:UIImage! // out here because it is not actually stored in the databse
struct userDataTypes {
    static let email = "email"
    static let name = "name"
    static let gender = "gender"
    static let provider = "provider"
    static let birthday = "birthday"
    static let barsUsed = "barsUsed"
    static let credits = "credits"
    static let membership = "membership"
    static let imgUrl = "imgUrl"
    static let stripeId = "stripeId"
    static let currentPeriodStart = "current_period_start"
    static let currentPeriodEnd = "current_period_end"
    static let billingDate = "billingDate"
   // static let pictureUrl = "pictureUrl"
}
//should be enumerate?
struct membershipLevels {
    static let basic = "Basic"
    static let premium = "Premium"
}

class User{
    var ref: FIRDatabaseReference!
    private var _membership:String!
    var membership:String!{
        set(newVal){
            _membership = newVal
            self.ref.child(userDataTypes.membership).setValue(membership)
            if self._membership == membershipLevels.premium {
                self._credits = 10
                if(self.currentPeriodStart == nil || self.currentPeriodEnd == nil){
                    self.setStandardPeriods()
                } else {
                    if ( currentPeriodEnd < NSDate().timeIntervalSince1970 ){
                        MyAPIClient.sharedClient.updatePeriods()
                    }
                }
            } else {
                self._credits = 1
                self.setStandardPeriods()
            }


        }
        get{
            return _membership
        }
    }

    /**
     If no period exits this sets the start period to today and end a month from now
    */
    private func setStandardPeriods(){
        self.currentPeriodStart = NSDate().timeIntervalSince1970
        self.currentPeriodEnd = NSDate().timeIntervalSince1970 + 30 * 24 * 60 * 60 // add a month
    }
    private var _credits:Int!
    var credits:Int! {
        set(newVal){
            self._credits = newVal
            self.ref.child(userDataTypes.credits).setValue(self._credits)
        }
        get{
            if self._credits < 0 {
                return 0
            } else {
                return self._credits
            }
        }
    }
    var currentPeriodStart:TimeInterval! {
        get { return _currentPeriodStart }
        set(newVal) {
            self._currentPeriodStart = newVal
            self.ref.child(userDataTypes.currentPeriodStart).setValue(self._currentPeriodStart) //update server
        }
    }
    private var _currentPeriodStart:TimeInterval!
    var currentPeriodEnd:TimeInterval! {
        get { return _currentPeriodEnd }
        set(newVal) {
            self._currentPeriodEnd = newVal
            self.ref.child(userDataTypes.currentPeriodStart).setValue(self._currentPeriodEnd) //update server
        }
    }
    private var _currentPeriodEnd:TimeInterval!

    var billingDate:String!
    var updatedCreditsDate:TimeInterval!
    var userKey:String!
    var name:String!
    var barsUsed:Dictionary<String,TimeInterval>!
    var key:String!
    var imgUrl:String!
    var usersImage:UIImage!
    var userEmail:String!
    var userBirthday:String!
    var gender:String!
    private var _stripeID:String!
    var stripeID:String?{
        set(newVal) {
            self.ref.child(userDataTypes.stripeId).setValue(newVal)
            self._stripeID = newVal
        }
        get{ return _stripeID }
    }

    init( userKey: String , userData: Dictionary<String, AnyObject> ){
        self.userKey = userKey
        if let name = userData[userDataTypes.name] as? String {
            self.name = name
        }
        if let imgUrl = userData[userDataTypes.imgUrl] as? String {
            self.imgUrl = imgUrl
        }
        if let stripeId =  userData[userDataTypes.stripeId] as? String {
            self._stripeID = stripeId
        }
        if let billingDate = userData[userDataTypes.billingDate] as? String {
            self.billingDate = billingDate
        }
        if let email = userData[userDataTypes.email] as? String {
            self.userEmail = email
        }

        if let barsUsed = userData[userDataTypes.barsUsed] as? Dictionary<String,TimeInterval>{
                print("Bars used - \(barsUsed)")
                self.barsUsed = barsUsed
            } else {
                print("No bars used")
                barsUsed  = [:]
        }
        if let membership = userData[userDataTypes.membership] as? String {
            self._membership = membership
        } else {
            self._membership = membershipLevels.basic
        }
        
        if let credits = userData[userDataTypes.credits] as? Int {
            self._credits = credits
        } else {
            if _membership == membershipLevels.premium {
                self._credits = 10
            } else {
                self._credits = 1
            }
        
            print("Backend: No Credits added")
        }
        if let currentPeriodStart = userData[userDataTypes.currentPeriodStart] as? TimeInterval {
            self._currentPeriodStart = currentPeriodStart
        }
        if let currentPeriodEnd = userData[userDataTypes.currentPeriodEnd] as? TimeInterval {
            self._currentPeriodEnd = currentPeriodEnd
        }

    
    }

    func getUserImg(returnBlock:((UIImage)->Void)?){
        print("CHUCK: getUserImg()")
        if let url = self.imgUrl {
            if let image = imageCache.object(forKey: url as NSString){
                self.usersImage = image
                returnBlock!(self.usersImage)
            } else {

                let nsUrl = NSURL(string: url as String)
                let urlRequest = NSURLRequest(url: nsUrl! as URL)
                let dataSession = URLSession.shared
                let dataTask = dataSession.dataTask(with: urlRequest as URLRequest, completionHandler:{ (data, response, error) in
                    if error == nil {
                        if let image = UIImage(data: data!) {
                            print("Chuck: successfully got image")
                            self.usersImage = image
                            imageCache.setObject(image, forKey: url as NSString)
                            returnBlock!(self.usersImage)
                        } else { print("Chuck: Could not get image from data") }
                    } else {  print("Chuck: error with loading image -\(error)") }
                })
                dataTask.resume() // needed or the above will never happen
            }
        } else { print("CHUCK: No imgUrl") }
    }
    
    
    func usedBar(barId:String, currentDate:TimeInterval){
        currentUser.barsUsed[barId] = currentDate
        currentUser.credits = currentUser.credits - 1

    }
}
