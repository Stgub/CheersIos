//
//  SplashVC.swift
//  Cheers
//
//  Created by Charles Fayal on 6/4/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SwiftKeychainWrapper

// reference : https://github.com/ashleymills/Reachability.swift
class SplashVC: UIViewController {
    let reachability = Reachability()!
    @IBOutlet weak var noInternetLabel: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                    name: ReachabilityChangedNotification,
                                                    object: reachability)
    }
    
    func reachabilityChanged(note: NSNotification) {
        print("SplashVC:reachabilityChanged")
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            noInternetLabel.isHidden = true

            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
            if currentUser != nil {
                presentBarFeedVC(sender: self)

            } else {
                if let _  = KeychainWrapper.standard.string(forKey: KEY_UID ){
                    print("CHUCK: ID found in keychain")
                    
                    MyFireBaseAPIClient.sharedClient.startObservingUser(){
                        presentBarFeedVC(sender: self)
                    }
                }
            }
        } else {
            print("Network not reachable")
            noInternetLabel.isHidden = false
            
        }
    }

}