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
    
    func getCurrentUser(returnBlock:(()->Void)? = nil){
        print("Grabbing current users info")
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            
            print(snapshot)
            let key = snapshot.key
            if let dataDict = snapshot.value as? Dictionary<String, AnyObject> {
                print("CHUCK: User Data Dict - \(dataDict)")
                let user = User(userKey: key , userData: dataDict)
                user.ref = snapshot.ref
                currentUser = user
                returnBlock!()
                
            } else { print("CHUCK: could not cast as Dictionary for user info")
            }
        })
    }
    func getBars(returnBlock:@escaping ([Bar])->Void){
        print("Backend: getting bars")
        DataService.ds.REF_BARS.observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                var returnedBars:[Bar] = []
                for snap in snapshots {
                    print("Backend: SNAP - \(snap)")
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
}
