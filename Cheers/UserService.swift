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
    private var _currentUser:User!
    
    static let sharedService = UserService()
    
    func getCurrentUser() -> User? {
        return _currentUser
    }
    
    func getStripeId() -> String? {
        return _currentUser.stripeID
    }
    
    func setStripeId(id:String){
        self._currentUser.stripeID = id
    }
    
    func isUserSignedIn() -> Bool {
        return _currentUser != nil
    }
    
    
    func updateUserMembership(membership:String){
        if membership != self._currentUser.membership {
            self._currentUser.ref.child(userDataTypes.membership).setValue(membership)
        }
    }
    
    func updateUserCredits(credits:Int){
        if credits != self._currentUser.credits {
            self._currentUser.ref.child(userDataTypes.credits).setValue(credits)
        }
    }
    
    func updateUser(data:Dictionary<String,String>){
        _currentUser.updateData(userData: data as Dictionary<String, AnyObject>)
    }
    
    func updateUser(){
        print(#function)
        if _currentUser.membership == membershipLevels.premium {
            StripeAPIClient.sharedClient.updateCustomer(user: _currentUser)
        } else {
            if _currentUser.currentPeriodEnd < NSDate().timeIntervalSince1970{
                self.updateUserCredits(credits: 1)
                let now =  NSDate().timeIntervalSince1970
                let aMonth:TimeInterval = 60*60*24*30 // in seconds
                if _currentUser.currentPeriodEnd + aMonth < now {
                    _currentUser.currentPeriodEnd = _currentUser.currentPeriodEnd + aMonth
                } else {
                    _currentUser.currentPeriodEnd = now + aMonth
                }
            }
        }
    }
    
    func updateUser(key:String,data:Dictionary<String, AnyObject>, completion:((Error?)-> Void)?){
        if let user = _currentUser {
            if let key = user.userKey {
                if  key == key {
                    _currentUser.updateData(userData: data)
                    print("Same user")
                }
            } else {
                let newUser = User(userKey: key, userData:data)
                _currentUser = newUser
                print("Changed User")
            }
        } else {
            let newUser = User(userKey: key, userData:data)
            _currentUser = newUser
            print("New User")
        }
        if completion != nil {
            completion!(nil)
        }
        self.updateUser()
    }
    
    func updateUserImg(image:UIImage, completion:@escaping ()-> Void)
    {
        _currentUser.usersImage = image
        
        _currentUser.saveUserImg(img: image, returnBlock: completion)
        
    }
    
    func redeemedDrink(bar:Bar, completion:@escaping ()->Void){
        let dateStamp = NSDate().timeIntervalSince1970
        DataService.ds.REF_USER_CURRENT.child(userDataTypes.barsUsed).child(bar.key).setValue(dateStamp){
            (error, ref) in
            if error != nil {
                print("Chuck: Error redeeming -\(String(describing: error))")
            } else {
                print("Successfully redeemed")
                var updateData = [ userDataTypes.barsUsed: dateStamp,
                                   userDataTypes.credits: self._currentUser.credits - 1 ] as [String : Any]
                self._currentUser.ref.updateChildValues(updateData)
            }
        }
    }
    
    func signOut(){
        print(#function)
        MyFireBaseAPIClient.sharedClient.stopObservingUser()
        try! Auth.auth().signOut()
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        _currentUser = nil
    }
    
    func facebookLogIn(loginController:LoginController){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: [ "public_profile", "email","user_birthday"], from: nil) { (result, error) in
            if error != nil {
                print("\(#function) error \(error.debugDescription)")
                loginController.loginFailed(title: "Error", message: "Please try again. Error - \(String(describing: error?.localizedDescription))")
                print("Chuck: Unable to authenticate with Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                loginController.loginFailed(title: "Cancelled", message: "User cancelled")
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
                                print("Chuck: Error with FB graph request - \(String(describing: error.debugDescription))")
                                loginController.loginFailed(title: "Error", message: "Please try again. Error - \(String(describing: error?.localizedDescription))")
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
                            self.firebaseAuth(loginController, credential: credential,userData:userData)
                    })
                }
            }
        }
    }

    func emailSignUp(loginController: LoginController,email:String,password:String, userData:[String:String]){
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
                            self.completeSignIn(loginController: loginController, id: user.uid, userData: userData)
                        } else {
                            print("Error verifying email \(error.debugDescription)")
                        }
                    })
                }
            } else {
                if let errCode = AuthErrorCode(rawValue: (error?._code)!) {
                    self.handleAuthErrorCodes(error: errCode, loginController: loginController)
                }
            }
        })
    }
    
    func emailLogIn(loginController: LoginController, email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if (error != nil) {
                // an error occurred while attempting login
                if let errCode = AuthErrorCode(rawValue: (error?._code)!) {
                    self.handleAuthErrorCodes(error: errCode, loginController: loginController)
                    
                }
            }else {
                print("Chuck: Email authenticated with Firebase")
                if error != nil {
                    loginController.loginFailed(title: "Error logging in", message: "Please try again")
                    print("Email verification error -\(error.debugDescription)")
                    do{
                        try Auth.auth().signOut()
                    } catch {
                        print("Error signging out after failed sign in ")
                    }
                } else {
                    if let user = user {

                        let userData = [
                            "provider": user.providerID,
                            "email" : user.email!
                        ]
                        self.completeSignIn(loginController: loginController, id: user.uid, userData: userData)
                    }
                }
                
            }
        })
    }
    
    func firebaseAuth(_ loginController: LoginController, credential: AuthCredential , userData:Dictionary<String, String>){
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if (error != nil) {
                // an error occurred while attempting login
                if let errCode = AuthErrorCode(rawValue: (error?._code)!) {
                    self.handleAuthErrorCodes(error: errCode, loginController: loginController)
                }
            } else {
                print("Chuck: Succesfully authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(loginController: loginController, id: user.uid, userData: userData)
                }
            }
        })
    }
    
    func completeSignIn(loginController: LoginController, id:String, userData:Dictionary<String, String>){
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let KeychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Chuck: Data saved to keycahain \(KeychainResult)")
        MyFireBaseAPIClient.sharedClient.getUser(completion:{_ in
            print(#function)
            loginController.loginComplete()
        })
    }

    func handleAuthErrorCodes(error: AuthErrorCode, loginController: LoginController){
        switch error {
        case .emailAlreadyInUse:
            loginController.loginFailed(title: "Email already in use", message: "Please try another email")
        case .invalidEmail:
            loginController.loginFailed(title: "Invalid Email", message: "Email is not in the correct format")
        case .wrongPassword:
            loginController.loginFailed(title: "Invalid Password", message: "Please enter the correct password")
        case .userNotFound:
            loginController.loginFailed(title: "User not found", message: "Make sure email is correct, or create an account")
        case .weakPassword:
               loginController.loginFailed(title: "Weak Password", message: "Please use a stronger password")
    
        default:
            
            print("ERROR: logging in \(error.rawValue)")
            loginController.loginFailed(title: "Error logging in", message: "Please try again - \(error.rawValue)")
        }
    }
}


