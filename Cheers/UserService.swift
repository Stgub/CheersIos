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

var currentUser:User!

//protocol UserObserver{
//    func updateUser()
//}

class UserService:NSObject {
    static let shareService = UserService()
    
//    var observer:UserObserver!
//    func addObserver(observer:UserObserver){
//        self.observer = observer
//    }
//    func removeObserver(observer:UserObserver){
//        self.observer = nil
//    }
//    
    func updateUser(){
        print(#function)
        if currentUser.membership == membershipLevels.premium {
            StripeAPIClient.sharedClient.updateCustomer()
        } else {
            if currentUser.currentPeriodEnd < NSDate().timeIntervalSince1970{
                currentUser.credits = 1
                let now =  NSDate().timeIntervalSince1970
                let aMonth:TimeInterval = 60*60*24*30 // in seconds
                if currentUser.currentPeriodEnd + aMonth < now {
                    currentUser.currentPeriodEnd = currentUser.currentPeriodEnd + aMonth
                } else {
                    currentUser.currentPeriodEnd = now + aMonth
                }
            }
        }
    }
    func signOut(){
        MyFireBaseAPIClient.sharedClient.stopObservingUser()
        try! Auth.auth().signOut()
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
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
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

    func emailSignUp(sender: UIViewController,email:String,password:String, userData:[String:String]){
        print("Signing up \(email)")
        var userData = userData
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                print("Chuck: Successfully authenticated with Firebase and email")
                if let user = user {
                    //TODO: to do something with email verification if needed?
                    user.sendEmailVerification(completion: { (error) in
                        if error == nil {
                            userData[userDataTypes.provider] = user.providerID
                            self.completeSignIn(sender: sender, id: user.uid, userData: userData)
                        } else {
                            print("Error verifying email \(error.debugDescription)")
                        }
                    })
                }
            } else {
                if let errCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch errCode {
                    case .emailAlreadyInUse:
                        presentUIAlert(sender:sender, title: "Email already in use", message: "Please try another email")
                    case .invalidEmail:
                        presentUIAlert(sender:sender, title: "Invalid Email", message: "Email is not in the correct format")
                    default:
                        print("Chuck: Erorr signing up with email - \(String(describing: error))")
                        
                    }
                }
            }
        })

        
    }
    
    func emailLogIn(sender: UIViewController, email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if (error != nil) {
                // an error occurred while attempting login
                if let errCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch errCode {
                    case .invalidEmail:
                        presentUIAlert(sender: sender ,title: "Invalid email", message: "Email is not in the correct format")
                    case .wrongPassword:
                        presentUIAlert(sender: sender ,title: "Invalid password", message: "Please enter the correct password")
                    case .userNotFound:
                        presentUIAlert(sender: sender ,title: "User not found", message: "Make sure email is correct, or create an account")
                    default:
                        presentUIAlert(sender: sender ,title: "Error logging in", message: "Please try again")
                        print("Chuck - Error logging in went to default error \(String(describing: error?.localizedDescription))")
                    }
                }
            }else {
            
                print("Chuck: Email authenticated with Firebase")
              
                if error != nil {
                    print("Email verification error -\(error.debugDescription)")
                } else {
                    if let user = user {

                        let userData = [
                            "provider": user.providerID,
                            "email" : user.email!
                        ]
                        self.completeSignIn(sender:sender, id: user.uid, userData: userData)
                    }
                }
                
            }
        })
        
    }
    
    func firebaseAuth(_ sender: UIViewController, credential: AuthCredential , userData:Dictionary<String, String>){
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if (error != nil) {
                // an error occurred while attempting login
                if let errCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch errCode {
                    case .invalidEmail:
                        presentUIAlert(sender: sender ,title: "Invalid email", message: "Email is not in the correct format")
                    case .wrongPassword:
                        presentUIAlert(sender: sender ,title: "Invalid password", message: "Please enter the correct password")
                    case .userNotFound:
                        presentUIAlert(sender: sender ,title: "User not found", message: "Make sure credentials are correct")
                    default:
                        presentUIAlert(sender: sender ,title: "Error logging in", message: "Please try again")
                        print("Chuck - Error logging in went to default error \(String(describing: error?.localizedDescription))")
                    }
                }
            } else {
                print("Chuck: Succesfully authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(sender: sender, id: user.uid, userData: userData)
                }
            }
        })
    }
    
 
    
    func completeSignIn(sender: UIViewController, id:String, userData:Dictionary<String, String>){
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let KeychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Chuck: Data saved to keycahain \(KeychainResult)")
        MyFireBaseAPIClient.sharedClient.getUser(completion:{_ in
            print(#function)
            GeneralFunctions.presentBarFeedVC(sender: sender)
            
        })
    }
}
