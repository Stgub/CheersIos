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
        if _currentUser == nil {
            print("Error: \(#function) current user is nil")
        }
        return _currentUser
    }
    
    func getStripeId() -> String? {
        return _currentUser.stripeID
    }
    
    func getMembershipLevel()-> String {
        return _currentUser.membership
    }
    
    func setStripeId(id:String){
        self._currentUser.stripeID = id
    }
    
    func isUserSignedIn() -> Bool {
        return _currentUser != nil
    }
    

    
    func updateUser(user:User){
        print(#function)
        if _currentUser.stripeID != nil {
            StripeAPIClient.sharedClient.updateCustomer(user: _currentUser)
        } else {
            print("UserService: User has no stripe Id, setting membership to basic and checking dates")
            user.membership = membershipLevels.basic
            updateBasicUser(user:user)
        }
    }
    //Updates periods without stripe data
    func updateBasicUser(user:User){
        print(#function)
        if user.currentPeriodEnd < NSDate().timeIntervalSince1970{
            user.credits = ConfigUtil.BASIC_NUM_CREDITS
            let now =  NSDate().timeIntervalSince1970
            if user.currentPeriodEnd + ConfigUtil.MONTH_IN_SEC < now {
                user.currentPeriodEnd = user.currentPeriodEnd + ConfigUtil.MONTH_IN_SEC
            } else {
                user.currentPeriodEnd = now + ConfigUtil.MONTH_IN_SEC
            }
        }
    }

    func updateUser(key:String,data:Dictionary<String, AnyObject>, completion:((Error?)-> Void)?){
        if let user = _currentUser {
            if let key = user.userKey {
                if  key == key {
                    _currentUser.initializeData(userData: data)
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
        self.updateUser(user:_currentUser)
        if completion != nil {
            completion!(nil)
        }
    }

    func redeemedDrink(bar:Bar, completion:@escaping (Error?)->Void){
        print(#function)
        let dateStamp = NSDate().timeIntervalSince1970
        DataService.ds.REF_USER_CURRENT.child(userDataTypes.barsUsed).child(bar.key).setValue(dateStamp){
            (error, ref) in
            if error != nil {
                print("Chuck: Error redeeming -\(String(describing: error))")
                completion(GeneralError(localizedDescription:(error?.localizedDescription)!))
            } else {
                print("Successfully redeemed")
                var barsUsed = self._currentUser.barsUsed
                barsUsed[bar.key] = dateStamp
                let updateData = [ userDataTypes.barsUsed: barsUsed,
                                   userDataTypes.credits: self._currentUser.credits - 1 ] as [String : AnyObject]
                self._currentUser.updateChildValues(data: updateData)
                completion(nil)
            }
        }
    }
    
    //MARK: Sign out and sign in methods 
    
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


