//
//  BarUtil.swift
//  Cheers
//
//  Created by Charles Fayal on 7/10/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation

public class BarUtil {
    static func isBarAvailable(bar:Bar)-> Bool {
        //Check the next availability of bar
        //TODO change this
        if let currentUser = UserService.sharedService.getCurrentUser() {
            if currentUser.barsUsed.keys.contains(bar.key){
                if let timeIntWhenUsed:TimeInterval = currentUser.barsUsed[bar.key] {
                    let dateUsed = Date(timeIntervalSince1970: timeIntWhenUsed)
                    if Date().timeIntervalSince1970 - timeIntWhenUsed < DAY_IN_SECS {
                        if Date().dayOfWeek() == dateUsed.dayOfWeek(){
                            return false
                        }
                    }
                }
            
            }
        }
        return true

    }
}
