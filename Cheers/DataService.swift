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
 //let SERVER_BASE = "http://52.41.104.17:5000"   // AWS server
 let SERVER_BASE = "http://0.0.0.0:5000" //local test


let DB_BASE = FIRDatabase.database().reference() // gives the URL of the root of the db, also in the google plist
let STORAGE_BASE = FIRStorage.storage().reference()
private var _REF_IMAGES = STORAGE_BASE.child("images")

class DataService {
    static let ds = DataService() //Singleton
    private var _REF_BASE = DB_BASE
    private var _REF_BARS = DB_BASE.child("bars")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_DEVICE_IDS = DB_BASE.child("deviceIds")
    private var _REF_BAR_IMAGES = STORAGE_BASE.child("bar-pics")
    
    //make private varibales globally accessible
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    var REF_BARS: FIRDatabaseReference {
        return _REF_BARS
    }
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    var REF_DEVICE_IDS: FIRDatabaseReference {  return _REF_DEVICE_IDS }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
        
    }
    var REF_BAR_IMAGES: FIRStorageReference {
        return _REF_BAR_IMAGES
    }
    
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String> ){
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        DataService.ds.REF_DEVICE_IDS.child(deviceID).setValue(uid) // Sets the device to the according account

        REF_USERS.child(uid).updateChildValues(userData) //will not wipe out a value that is already there.. set value will
    }
    
    
    
}
