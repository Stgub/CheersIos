//
//  User.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import UIKit
var userImage:UIImage! // out here because it is not actually stored in the databse
struct userDataTypes {
    static let email = "email"
    static let name = "name"
    static let gender = "gender"
    static let provider = "provider"
    static let birthday = "birthday"
    static let barsUsed = "barsUsed"
    
    static let imgUrl = "imgUrl"
   // static let pictureUrl = "pictureUrl"
}

class User{
    var userKey:String!
    var name:String!
    var barsUsed:[String]!
    var key:String!
    var imgUrl:String!
    var usersImage:UIImage!
    var userEmail:String!
    var userBirthday:String!
    var gender:String!

    init( userKey: String , userData: Dictionary<String, AnyObject> ){
        self.userKey = userKey
        if let name = userData[userDataTypes.name] as? String {
            self.name = name
        }
        if let imgUrl = userData[userDataTypes.imgUrl] as? String {
            self.imgUrl = imgUrl
        }
    
    }

    func getUserImg(returnBlock:((UIImage)->Void)?){
        print("CHUCK: getUserImg()")
        if let url = self.imgUrl {
            let nsUrl = NSURL(string: url as String)
            let urlRequest = NSURLRequest(url: nsUrl! as URL)
            let dataSession = URLSession.shared
            let dataTask = dataSession.dataTask(with: urlRequest as URLRequest, completionHandler:{ (data, response, error) in
                if error == nil {
                    if let image = UIImage(data: data!) {
                        print("Chuck: successfully got image")
                        self.usersImage = image
                        returnBlock!(self.usersImage)
                    } else { print("Chuck: Could not get image from data") }
                } else {  print("Chuck: error with loading image -\(error)") }
            })
            dataTask.resume() // needed or the above will never happen
        } else { print("CHUCK: No imgUrl") }
    }
    
    
    func usedBar(barId:String){
    
    }
}
