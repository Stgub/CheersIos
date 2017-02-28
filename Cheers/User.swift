//
//  User.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import UIKit

struct userDataTypes {
    static let email = "email"
    static let name = "name"
    static let gender = "gender"
    static let provider = "provider"
    static let birthday = "birthday"
    static let likes = "likes"
    static let posts = "posts"
}

class User{
    var name:String!
    var picture:UIImage!
    var pictureUrl:String!
    
    var key:String!
    
    init( userKey: String , userData: Dictionary<String, AnyObject> ){
        self.key = userKey
        if let name = userData[userDataTypes.name] as? String {
            self.name = name
        } else {
            print("Chuck: Do not have users name")
            self.name = "Anonymous"
        }
    }
}
