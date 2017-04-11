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
    static let billingDate = "billing-date"
    static let imgUrl = "imgUrl"
    static let stripeId = "stripeId"
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
    
    private func setMembership(membership:String){
        self._membership = membership
        if _membership == membershipLevels.premium{
            self.credits = 10
        } else{
            self.credits = 1
        }
    }
    var membership:String! {
        get {
            return self._membership
        }
    }
    func setMembership(membership:String, completion:@escaping (_ error:Error?)->Void){
        self.ref.child(userDataTypes.membership).setValue(membership) { (error, ref) in
            if error != nil {
                print("Error setting membership - \(error))")
                completion(error)
            } else {
                completion(nil)
                self.setMembership(membership: membership)
            }
        }
    }
    private var _credits:Int!
    var credits:Int! {
        set(newVal){
            self._credits = newVal
            for (_ , date) in self.barsUsed {
                
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "MM/dd/yyyy"
                let dateUsed = dateFormater.date(from: date)
                let timeFromNow = (dateUsed?.timeIntervalSinceNow)! / (60 * 60 * 24 * 30)
                print("Date from now: \(timeFromNow)")
                if timeFromNow > -30 {
                    self._credits! -= 1
                }
            }
        }
        get{
            if self._credits < 0 {
                return 0
            } else {
                return self._credits
            }
        }
    }
    var billingDate:String!
    var userKey:String!
    var name:String!
    var barsUsed:Dictionary<String,String>!
    var key:String!
    var imgUrl:String!
    var usersImage:UIImage!
    var userEmail:String!
    var userBirthday:String!
    var gender:String!
    private var _stripeID:String!
    var stripeID:String?{
        get{ return _stripeID }
    }
    func setStripeID(stripeID:String, completion:@escaping (_ error:Error?)->Void){
        self.ref.child(userDataTypes.stripeId).setValue(stripeID) { (error, ref) in
            if error != nil {
                print("Error setting stripeID - \(error))")
                completion(error)
            } else {
                completion(nil)
                self._stripeID = stripeID
            }
        }
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

        if let barsUsed = userData[userDataTypes.barsUsed] as? Dictionary<String,String>{
                print("Bars used - \(barsUsed)")
                self.barsUsed = barsUsed
            } else {
                print("No bars used")
                barsUsed  = [:]
        }
        if let membership = userData[userDataTypes.membership] as? String {
            self.setMembership(membership: membership)
        } else {
            self.setMembership(membership:membershipLevels.basic)
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
    
    
    func usedBar(barId:String, currentDate:String){
        currentUser.barsUsed[barId] = currentDate
        currentUser.credits = currentUser.credits - 1

    }
}
