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
struct userDataTypes {
    static let email = "email"
    static let phoneNumber = "phoneNumber"
    static let name = "name"
    static let gender = "gender"
    static let provider = "provider"
    static let birthday = "birthday"
    static let barsUsed = "barsUsed"
    static let credits = "credits"
    static let membership = "membership"
    static let stripeId = "stripeId"
    static let testStripeId = "testStripeId"
    static let connectId = "connectId"
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
    
    var myDbAPI: MyFireBaseAPIClient = MyFireBaseAPIClient.sharedClient
    private var ref: DatabaseReference!
    
    private var _membership:String = membershipLevels.basic
    var membership:String{
        get{
            return _membership
        }
        set{
            if newValue != self._membership {
                self._membership = newValue
                self.ref.child(userDataTypes.membership).setValue(self._membership)
                if self._membership == membershipLevels.basic {
                    self.credits = ConfigUtil.BASIC_NUM_CREDITS
                } else {
                    self.credits = ConfigUtil.PREMIUM_NUM_CREDITS
                }
            }
        }
    }
    
    private var _credits:Int = 1
    var credits:Int! {
        get{
            if self._credits < 0 {
                return 0
            } else {
                return self._credits
            }
        }
        set{
            if newValue != self._credits {
                self._credits = newValue
                self.ref.child(userDataTypes.credits).setValue(self._credits)
            }
        }
    }
    
    private var _currentPeriodStart:TimeInterval!
    var currentPeriodStart:TimeInterval! {
        get { return _currentPeriodStart }
        set {
            if newValue != self._currentPeriodStart {
                self._currentPeriodStart = newValue
                self.ref.child(userDataTypes.currentPeriodStart).setValue(newValue) //update server
            }
        }
    }
    
    private var _currentPeriodEnd:TimeInterval!
    var currentPeriodEnd:TimeInterval! {
        get { return _currentPeriodEnd }
        set {
            if newValue != self._currentPeriodEnd {
                self._currentPeriodEnd = newValue
                self.ref.child(userDataTypes.currentPeriodEnd).setValue(newValue) //update server
            }
        }
    }

    private var _userKey:String!
    var userKey:String!{
        get{ return _userKey }
    }
    private var  _name:String!
    var name:String {
        get{ return _name }
        set {
            print("Changing users name to \(newValue)")
            self.ref.child(userDataTypes.name).setValue(newValue)
        }
    }
    private var _barsUsed:Dictionary<String,TimeInterval> = [:]
    var barsUsed:Dictionary<String,TimeInterval> {
        get{ return _barsUsed }
    }

    private var _userEmail:String!
    var userEmail:String! {
        get{ return _userEmail }
        set(newVal){
            print("Changing users email to \(newVal)")
            self._userEmail = userEmail
            ref.child(userDataTypes.email).setValue(newVal)
        }
    }
    private var _phoneNumber:String!
    var phoneNumber:String!{
        get{ return _phoneNumber}
        set(newVal){
            print("Adding phone number\(newVal)")
            self._phoneNumber = newVal
            ref.child(userDataTypes.phoneNumber).setValue(newVal)
        }
    }
    
    var userBirthday:String!
    var gender:String!
    
    private var _stripeID:String!
    var stripeID:String?{
        get{ return _stripeID }
        set{
            var child:String
            if ConfigUtil.inTesting {
                child = userDataTypes.testStripeId
            } else {
                child = userDataTypes.stripeId
            }
            self.ref.child(child).setValue(newValue)
        }
    }
    
    

    init( userKey: String , userData: Dictionary<String, AnyObject> ){
        self._userKey = userKey
        self.initializeData(userData: userData)
    }
    
    func initializeData(userData:Dictionary<String,AnyObject>){
        
        self.ref = DataService.ds.REF_USER_CURRENT
        if let name = userData[userDataTypes.name] as? String {
            self._name = name
        } else {
            self._name = "Anonymous" //TODO need to make sure we get users name
        }
        
        var stripeKey:String
        if ConfigUtil.inTesting {
            stripeKey = userDataTypes.testStripeId
        } else {
            stripeKey = userDataTypes.stripeId
        }
        
        if let stripeId =  userData[stripeKey] as? String {
            self._stripeID = stripeId
        }
        
        if let email = userData[userDataTypes.email] as? String {
            self._userEmail = email
        }
        
        if let barsUsed = userData[userDataTypes.barsUsed] as? Dictionary<String,TimeInterval>{
            print("Bars used - \(barsUsed)")
            self._barsUsed = barsUsed
        } else { print("User: No bars used could not cast") }
        
        if let membership = userData[userDataTypes.membership] as? String {
            self._membership = membership
        } else { print("User: no membership in data") }
        
        if let credits = userData[userDataTypes.credits] as? Int {
            self._credits = credits
        } else { print("User: no credits in data" ) }
        
        if let currentPeriodStart = userData[userDataTypes.currentPeriodStart] as? TimeInterval {
            self._currentPeriodStart = currentPeriodStart
            print("User: start date from FireBase")
        } else {
            self.currentPeriodStart = NSDate().timeIntervalSince1970
            print("User: added new arbitrary periodStart date")
        }
        
        if let currentPeriodEnd = userData[userDataTypes.currentPeriodEnd] as? TimeInterval {
            self._currentPeriodEnd = currentPeriodEnd
            print("User: end date from FB")
        } else {
            self.currentPeriodEnd = NSDate().timeIntervalSince1970 + ConfigUtil.MONTH_IN_SEC
            print("User: added new arbitrary periodEnd date")
        }
        
        if let phoneNum = userData[userDataTypes.phoneNumber] as? String {
            self._phoneNumber = phoneNum
        }
        //Notitify user observers, that info has updated so they can change UI etc
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationKeys.userObserver.rawValue), object: self)

    }
    
    
    func updateChildValues(data: Dictionary<String, AnyObject>){
        self.ref.updateChildValues(data)
    }
    
    
}
