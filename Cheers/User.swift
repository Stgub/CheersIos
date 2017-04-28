//
//  User.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//


/**
 Implement the following to not update the whole user every time something changes
 FIRDataEventTypeValue – Read and listen for changes to the entire contents of a path.
 FIRDataEventTypeChildAdded – Retrieve lists of items or listen for additions to a list of items. Suggested use with FIRDataEventTypeChildChanged and FIRDataEventTypeChildRemoved to monitor changes to lists.
 FIRDataEventTypeChildChanged – Listen for changes to the items in a list. Use with FIRDataEventTypeChildAdded and FIRDataEventTypeChildRemoved to monitor changes to lists.
 FIRDataEventTypeChildRemoved – Listen for items being removed from a list. Use with FIRDataEventTypeChildAdded and FIRDataEventTypeChildChanged to monitor changes to lists.
 FIRDataEventTypeChildMoved – Listen for changes to the order of items in an ordered list. FIRDataEventTypeChildMoved events always follow the FIRDataEventTypeChildChanged event that caused the item’s order to change (based on your current order-by method).
 info at : https://www.sitepoint.com/creating-a-firebase-backend-for-ios-app/
 */

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
            self.ref.child(userDataTypes.membership).setValue(newVal)
            if newVal == membershipLevels.premium {
                credits = 10
            } else {
                credits = 1
            }
        }
        get{
            return _membership
        }
    }
    private var _credits:Int!
    var credits:Int! {
        set(newVal){
            self.ref.child(userDataTypes.credits).setValue(newVal)
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
            self.ref.child(userDataTypes.currentPeriodStart).setValue(newVal) //update server
        }
    }
    private var _currentPeriodStart:TimeInterval!
    var currentPeriodEnd:TimeInterval! {
        get { return _currentPeriodEnd }
        set(newVal) {
            self._currentPeriodEnd = newVal
            self.ref.child(userDataTypes.currentPeriodEnd).setValue(newVal) //update server
        }
    }
    private var _currentPeriodEnd:TimeInterval!

    var updatedCreditsDate:TimeInterval!
    private var _userKey:String!
    var userKey:String!{
        get{ return _userKey }
    }
    private var  _name:String!
    var name:String {
        get{ return _name }
    }
    private var _barsUsed:Dictionary<String,TimeInterval> = [:]
    var barsUsed:Dictionary<String,TimeInterval> {
        get{ return _barsUsed }
    }
    var _imgUrl:String!
    var usersImage:UIImage!
    private var _userEmail:String!
    var userEmail:String! {
        get{ return _userEmail }
        set(newVal){
            self._userEmail = userEmail
            ref.child(userDataTypes.email).setValue(newVal)
        }
    }
    var userBirthday:String!
    var gender:String!
    private var _stripeID:String!
    var stripeID:String?{
        set(newVal) {
            self._stripeID = stripeID
            self.ref.child(userDataTypes.stripeId).setValue(newVal)
        }
        get{ return _stripeID }
    }
    
    init( userKey: String , userData: Dictionary<String, AnyObject> ){
        self._userKey = userKey
        self.updateData(userData: userData)
    
    }
    
    func updateData(userData:Dictionary<String,AnyObject>){
        self.ref = DataService.ds.REF_USER_CURRENT
        if let name = userData[userDataTypes.name] as? String {
            self._name = name
        } else {
            self._name = "Anonymous" //TODO need to make sure we get users name
        }
        if let imgUrl = userData[userDataTypes.imgUrl] as? String {
            self._imgUrl = imgUrl
        }
        if let stripeId =  userData[userDataTypes.stripeId] as? String {
            self._stripeID = stripeId
        }
        
        if let email = userData[userDataTypes.email] as? String {
            self._userEmail = email
        }
        
        if let barsUsed = userData[userDataTypes.barsUsed] as? Dictionary<String,TimeInterval>{
            print("Bars used - \(barsUsed)")
            self._barsUsed = barsUsed
        } else {
            print("No bars used could not cast")
            _barsUsed  = [:]
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
                self.credits = 10
            } else {
                self._credits = 1
                self.credits = 1
            }
            
            print("Backend: No Credits information on Firebase")
        }
        if let currentPeriodStart = userData[userDataTypes.currentPeriodStart] as? TimeInterval {
            self._currentPeriodStart = currentPeriodStart
            print("Backend: start date from FB")
        } else {
            self.currentPeriodStart = NSDate().timeIntervalSince1970
            print("Backend: added new arbitrary periodStart date")

        }
        if let currentPeriodEnd = userData[userDataTypes.currentPeriodEnd] as? TimeInterval {
            self._currentPeriodEnd = currentPeriodEnd
            print("Backend: end date from FB")

        } else {
            self.currentPeriodEnd = NSDate().timeIntervalSince1970 + 60 * 60 * 24 * 30
            print("Backend: added new arbitrary periodEnd date")
        }


    }

    func getUserImg(returnBlock:((UIImage?)->Void)?){
        print("CHUCK: getUserImg()")
        if let url = self._imgUrl {
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
        } else { print("Backend: User has no imgUrl ") }
    }
    
    
    func usedBar(barId:String, currentDate:TimeInterval){
        ref.child(userDataTypes.barsUsed).child(barId).setValue(currentDate)
        ref.child(userDataTypes.credits).setValue(self._credits - 1)

    }
}
