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

    override func viewDidLoad() {
        print("Splah screen loaded")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Splash screen appeared")
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        update()
        do{
            print("starting notifier")
            try reachability.startNotifier() // does an update automatically
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
        //let reachability = note.object as! Reachability
        self.update()
    }
    func update(){
        if !reachability.isReachable {
            print("Network not reachable")
            noInternetLabel.isHidden = false
            return
        }
        
        noInternetLabel.isHidden = true
        if reachability.isReachableViaWiFi {
            print("Reachable via WiFi")
        } else {
            print("Reachable via Cellular")
        }
        
        if UserService.sharedService.isUserSignedIn() {
            print("Splash - user already signed in")
            GeneralFunctions.presentBarFeedVC(sender: self)
            return
        }
        
        if let _  = KeychainWrapper.standard.string(forKey: KEY_UID ){
            print("SplashVC - found user in key chain")
            MyFireBaseAPIClient.sharedClient.getUser{ (userError) in
                if userError == nil {
                    print("SplashVC \(#function) presentingBarVC:")
                    GeneralFunctions.presentBarFeedVC(sender: self)
                } else {
                    print("SplashVC \(#function) error getting user - \(userError?.localizedDescription)")
                    UserService.sharedService.signOut()
                    GeneralFunctions.presentFirstLoginVC(sender: self)
                }
            }
        } else {
            print("SplashVC - no user in key chain, send to login screen")
            GeneralFunctions.presentFirstLoginVC(sender: self)
        }

    }

}
