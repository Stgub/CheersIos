//
//  UserService.swift
//  Cheers
//
//  Created by Charles Fayal on 4/23/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation

class UserService {
    static let shareService = UserService()

    func signIn(completion:@escaping ()->Void){
        MyFireBaseAPIClient.sharedClient.startObservingUser(){
            completion()
        }}
    func signOut(){
        MyFireBaseAPIClient.sharedClient.stopObservingUser()
    }
    //TODO should migrate sign in functions here
}
