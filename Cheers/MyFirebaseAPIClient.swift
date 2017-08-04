//
//  MyFirebaseAPIClient.swift
//  Cheers
//
//  Created by Charles Fayal on 4/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import Firebase

class MyFireBaseAPIClient:NSObject{
    static let sharedClient = MyFireBaseAPIClient()
    override init() { }

    private var watchdogTimer:Timer = Timer()
    
    func getBars(returnBlock:@escaping ([Bar])->Void){
        print("Backend: getting bars")
        DataService.ds.REF_BARS.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                var returnedBars:[Bar] = []
                for snap in snapshots {
                    //print("Backend: SNAP - \(snap)")
                    if let barData = snap.value as? Dictionary<String, AnyObject>{
                        let newBar = Bar(barKey: snap.key, dataDict: barData)
                        returnedBars.append(newBar)
                    }
                }
                print("Returning num bars: \(returnedBars.count)")
                returnBlock(returnedBars)
            }
        })
    }

    
    func getUser( completion:@escaping  (Error?)-> Void )
    {
        print(#function)
        print(DataService.ds.REF_USER_CURRENT)
        
        
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            print("Observed User")
            if !snapshot.exists() {
                print("ERROR: User does not exist")
                UserService.sharedService.signOut()
            }
            let snapKey = snapshot.key
            if let userData = snapshot.value as? Dictionary<String,AnyObject>{
                UserService.sharedService.updateUser(key: snapKey, data: userData, completion: completion)
                self.startObservingUser()
            } else { print("Error - cast issue probably not a user")
                completion(GeneralError(localizedDescription: "Could not get user"))
            }
        }) { (error) in
            print("Error: \(#function) \(error.localizedDescription)")
            completion(userError(localizedDescription: error.localizedDescription))
        }
    }
    
    private var observeUserHandle: DatabaseHandle!
    /**
     Used to get the current user and update the user whenever anything changes, should be used at any sign in 
     */
    func startObservingUser() {
        print(#function)
        observeUserHandle = DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot) in
            print("Observed User")
            //Update current User
            let snapKey = snapshot.key
            if let userData = snapshot.value as? Dictionary<String,AnyObject>{
                UserService.sharedService.updateUser(key: snapKey, data: userData, completion: nil)
            }
        }){ (error) in
            print("Error")
            print(error.localizedDescription)
        }
    }
    
    //MARK: - User functions 
    
    deinit {
        print("denit observing user")
        DataService.ds.REF_USER_CURRENT.removeObserver(withHandle: observeUserHandle)
    }
    
    func stopObservingUser(){
        print(#function)
        if let handle = observeUserHandle {
            DataService.ds.REF_USER_CURRENT.removeObserver(withHandle: handle)
        }
    }
    
    func saveUserImg(img:UIImage, path:String,returnBlock:@escaping (_ path:String)-> Void){
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let data = UIImageJPEGRepresentation(img, 0.8)
        DataService.ds.REF_USER_IMAGES.child(path).putData(data!, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                //store downloadURL at database
                returnBlock(downloadURL)
            }
            
        }
    }
}
