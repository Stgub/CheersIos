//
//  DataService.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//


import Foundation
import Firebase
import SwiftKeychainWrapper

var imageCache: NSCache<NSString, UIImage> = NSCache()



let DB_BASE = Database.database().reference() // gives the URL of the root of the db, also in the google plist
let STORAGE_BASE = Storage.storage().reference()
private var _REF_IMAGES = STORAGE_BASE.child("images")

class DataService {
    static let ds = DataService() //Singleton
    private var _REF_BASE = DB_BASE
    private var _REF_BARS = DB_BASE.child("bars")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_BAR_IMAGES = STORAGE_BASE.child("bar-pics")
    private var _REF_USER_IMAGES = STORAGE_BASE.child("user-pics")
    //make private varibales globally accessible
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    var REF_BARS: DatabaseReference {
        return _REF_BARS
    }
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
        
    }
    var REF_BAR_IMAGES: StorageReference {
        return _REF_BAR_IMAGES
    }
    var REF_USER_IMAGES: StorageReference {
        return _REF_USER_IMAGES
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, Any> ){
        REF_USERS.child(uid).updateChildValues(userData) //will not wipe out a value that is already there.. set value will
    }
    
    
    
}
