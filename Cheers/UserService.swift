//
//  UserService.swift
//  Cheers
//
//  Created by Charles Fayal on 4/23/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper
import FBSDKLoginKit

class UserService:NSObject {
    static let shareService = UserService()

    func signOut(){
        MyFireBaseAPIClient.sharedClient.stopObservingUser()
        try! FIRAuth.auth()!.signOut()
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        currentUser = nil
    }
    
    func facebookLogIn(sender:UIViewController){
            let facebookLogin = FBSDKLoginManager()
            facebookLogin.logIn(withReadPermissions: [ "public_profile", "email","user_birthday"], from: sender) { (result, error) in
                if error != nil {
                    print("Chuck: Unable to authenticate with Facebook - \(String(describing: error))")
                } else if result?.isCancelled == true {
                    print("Chuck: User cancelled Facebook authentication")
                } else {
                    print("Chuck: Successfully authenticated with Facebook")
                    print("result \(String(describing: result))")
                    //Authenticate with Facebook
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    //Authenticatre with Firebase
                    var userData = [userDataTypes.provider: credential.provider]
                    //Grab user info
                    if((FBSDKAccessToken.current()) != nil){
                        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name,  email, gender, birthday, picture.type(large)"]).start(completionHandler:
                            { (connection, result, error) -> Void in
                                print("Chuck: Graph request connection? \(String(describing: connection))")
                                if error != nil {
                                    print("Chuck: Error with FB graph request - \(String(describing: error))")
                                } else {
                                    print("Chuck: Result from FB graph request - \(String(describing: result))")
                                    if let result = result as? NSDictionary {
                                        if let birthday = result["birthday"] as? String{
                                            //let dateFormatter = DateFormatter()
                                            ///dateFormatter.dateFormat = "dd/MM/yyyy"
                                            //let date = dateFormatter.date(from: birthday)
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
                                self.firebaseAuth(sender, credential: credential,userData:userData)
                        })
                    }
                    
                }
                
            }
        }

    
    
    func firebaseAuth(_ sender: UIViewController, credential: FIRAuthCredential , userData:Dictionary<String, String>){
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Chuck: Unable to authenticate with Firebase - \(String(describing: error))")
                
            } else {
                print("Chuck: Succesfully authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(sender: sender, id: user.uid, userData: userData)
                }
            }
        })
    }
    
    func emailLogIn(sender: UIViewController, email: String, password: String){
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if (error != nil) {
                // an error occurred while attempting login
                if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                    switch errCode {
                    case .errorCodeInvalidEmail:
                        presentUIAlert(sender: sender ,title: "Invalid email", message: "Email is not in the correct format")
                    case .errorCodeWrongPassword:
                        presentUIAlert(sender: sender ,title: "Invalid password", message: "Please enter the correct password")
                    case .errorCodeUserNotFound:
                        presentUIAlert(sender: sender ,title: "User not found", message: "Make sure email is correct, or create an account")
                    default:
                        presentUIAlert(sender: sender ,title: "Error logging in", message: "Please try again")
                        print("Chuck - Error logging in went to default error \(String(describing: error?.localizedDescription))")
                    }
                }
            }else {
                print("Chuck: Email authenticated with Firebase")
                if let user = user {
                    let userData = [
                        "provider": user.providerID,
                        "email" : user.email!
                    ]
                    self.completeSignIn(sender:sender, id: user.uid, userData: userData)
                }
            }
        })
        
    }
    
    func completeSignIn(sender: UIViewController, id:String, userData:Dictionary<String, String>){
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
                        presentUIAlert(sender: sender, title: "Device is already associated with an account", message: "Please contact support at support@GetToastApp.com")
                        return
                    }
                })
            }
        })
    
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let KeychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Chuck: Data saved to keycahain \(KeychainResult)")
        MyFireBaseAPIClient.sharedClient.getUser(completion:{_ in
            print(#function)
            GeneralFunctions.presentBarFeedVC(sender: sender)
            
        })
    }
}
