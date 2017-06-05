//
//  LogInOrSignUpVC.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import SwiftKeychainWrapper

class FirstLoginVC: UIViewController {

    @IBAction func fbBtnTapped(_ sender: UIButton) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: [ "public_profile", "email","user_birthday"], from: self) { (result, error) in
            if error != nil {
                print("Chuck: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("Chuck: User cancelled Facebook authentication")
            } else {
                print("Chuck: Successfully authenticated with Facebook")
                print("result \(result)")
                //Authenticate with Facebook
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                //Authenticatre with Firebase
                var userData = [userDataTypes.provider: credential.provider]
                //Grab user info
                if((FBSDKAccessToken.current()) != nil){
                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name,  email, gender, birthday, picture.type(large)"]).start(completionHandler:
                        { (connection, result, error) -> Void in
                            print("Chuck: Graph request connection? \(connection)")
                            if error != nil {
                                print("Chuck: Error with FB graph request - \(error)")
                            } else {
                                print("Chuck: Result from FB graph request - \(result)")
                                if let result = result as? NSDictionary {
                                    if let birthday = result["birthday"] as? String{
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "dd/MM/yyyy"
                                        let date = dateFormatter.date(from: birthday)
                                        //print("birthday day formatted")
                                        /* let age = (date?.timeIntervalSinceNow)! / (60 * 60 * 24 * 365)
                                        if age > -21 {
                                            presentUIAlert(sender: self, title: "Does not meet age requirements", message: "User must be over 21 to use")
                                            return
                                        }*/
                                        userData[userDataTypes.birthday] = birthday
                                    } else { print("Chuck: Could'nt grab FB birthday")}
                                    if let email = result["email"] as? String{
                                        userData[userDataTypes.email] = email
                                    } else { print("Chuck: Could'nt grab FB email")}
                                    if let name = result["name"] as? String {
                                        userData[userDataTypes.name] = name
                                    } else { print("Chuck: Could'nt grab FB name")}
                                    
                                    if let gender = result["gender"] as? String {
                                        userData[userDataTypes.gender] = gender
                                    } else { print("Chuck: Could'nt grab FB gender")}
                                    if let picture = result["picture"] as? NSDictionary {
                                        let data = picture["data"] as! NSDictionary
                                        let imgURL = data["url"]
                                        print("setting URL")
                                        userData[userDataTypes.imgUrl] = imgURL as! String?
                                        
                                    } else { print("Chuck : No facebook image grabbed") }
                                } else { print("Chuck: Could'nt cast result to NSDictionary") }
                            }
                            self.firebaseAuth(credential,userData:userData)
                    })
                }
                
            }
            
        }
    }
    
    
    
    func firebaseAuth(_ credential: FIRAuthCredential , userData:Dictionary<String, String>){
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Chuck: Unable to authenticate with Firebase - \(error)")
                
            } else {
                print("Chuck: Succesfully authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(id: user.uid,userData: userData)
                }
            }
        })
    }
    func completeSignIn(id:String, userData:Dictionary<String, String>){
        // for automatic sign in
        //Check if there is a user with ID
        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with:{
            (snapshot) in
            if snapshot.hasChild(id) {
            
            } else {
                //If there is not a user with ID but this device is already associated with an account, don't let them create multiple accounts on device
                 DataService.ds.REF_DEVICE_IDS.observeSingleEvent(of: .value, with: {
                    (deviceSnapshot) in
                    let deviceId = UIDevice.current.identifierForVendor!.uuidString
                    if deviceSnapshot.hasChild(deviceId) {
                        presentUIAlert(sender: self, title: "Device is already associated with an account", message: "Please contact support at support@GetToastApp.com")
                        return
                    }
                })
            }
        })
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let KeychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Chuck: Data saved to keycahain \(KeychainResult)")
        MyFireBaseAPIClient.sharedClient.startObservingUser(completion:{
                presentBarFeedVC(sender: self)

            })
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
