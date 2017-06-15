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

    func getBars(returnBlock:@escaping ([Bar])->Void){
        print("Backend: getting bars")
        DataService.ds.REF_BARS.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
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
    
    private var observeUserHandle: FIRDatabaseHandle!
    
    /**
     Used to get the current user and update the user whenever anything changes, should be used at any sign in 
     */
    func startObservingUser(completion:@escaping ()->Void) {
        print("startObservingUser")
        observeUserHandle = DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot) in
            print("Observed User")
            //Update current User
            let snapKey = snapshot.key
            if let userData = snapshot.value as? Dictionary<String,AnyObject>{
                if let user = currentUser {
                    if let key = user.userKey {
                        if  key == snapKey {
                            currentUser.updateData(userData: userData)
                            print("Same user")
                        }
                    } else {
                        let newUser = User(userKey: snapKey, userData:userData)
                        currentUser = newUser
                        print("Changed User")
                    }
                } else {
                    let newUser = User(userKey: snapKey, userData:userData)
                    currentUser = newUser
                    print("New User")
                }
                print("Completion")
                completion()
            } else { print("Could not cast 2")}
        })
    }
    
    //MARK: - User functions 
    
    deinit {
        DataService.ds.REF_USER_CURRENT.removeObserver(withHandle: observeUserHandle)
    }
    func stopObservingUser(){
        DataService.ds.REF_USER_CURRENT.removeObserver(withHandle: observeUserHandle)

    }
    func saveUserImg(img:UIImage, path:String,returnBlock:@escaping (_ path:String)-> Void){
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        let data = UIImageJPEGRepresentation(img, 0.8)
        DataService.ds.REF_USER_IMAGES.child(path).put(data!, metadata: metaData){(metaData,error) in
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
