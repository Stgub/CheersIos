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
    
    //used to get a paragraph of the bar hours for labels throughout the app
    static func getHoursParagraph(hoursOpen:Dictionary<String,Int>)-> String{
        var barHoursPara = ""
        var dayString = getDayString(hoursOpen: hoursOpen, dayAbbrv: "mon")
        if !dayString.isEmpty {
            barHoursPara += "Mon. \(dayString),\n"
        }
        dayString = getDayString(hoursOpen: hoursOpen, dayAbbrv: "tues")
        if !dayString.isEmpty {
            barHoursPara += "Tue. \(dayString),\n"
        }
        dayString = getDayString(hoursOpen: hoursOpen, dayAbbrv: "weds")
        if !dayString.isEmpty {
            barHoursPara += "Wed. \(dayString),\n"
        }
        dayString = getDayString(hoursOpen: hoursOpen, dayAbbrv: "thu")
        if !dayString.isEmpty {
            barHoursPara += "Thurs. \(dayString),\n"
        }
        dayString = getDayString(hoursOpen: hoursOpen, dayAbbrv: "fri")
        if !dayString.isEmpty {
            barHoursPara += "Fri. \(dayString),\n"
        }
        dayString = getDayString(hoursOpen: hoursOpen, dayAbbrv: "sat")
        if !dayString.isEmpty {
            barHoursPara += "Sat. \(dayString),\n"
        }
        dayString = getDayString(hoursOpen: hoursOpen, dayAbbrv: "sat")
        if !dayString.isEmpty {
            barHoursPara += "Sun. \(dayString)"
        }
        return barHoursPara
    }
    static private func getDayString(hoursOpen:Dictionary<String,Int>,dayAbbrv:String)-> String{
        let openTime = self.getHoursString(militaryTime: hoursOpen[dayAbbrv + "Open"])
        let closeTime = self.getHoursString(militaryTime: hoursOpen[dayAbbrv + "Close"])
        if openTime.isEmpty || closeTime.isEmpty {
            return ""
        } else {
            return openTime + "-" + closeTime
        }
    }
    static private func getHoursString(militaryTime:Int?)->String{
        guard militaryTime != nil else {
            return ""
        }
        let hour = militaryTime! / 100
        let minute = militaryTime! % 100
        var timeHour :Int = -1
        var amPm:String = ""
        if hour < 1 {
            timeHour = 12
            amPm = "am"
        } else if hour > 1 && hour < 12 {
            timeHour = hour
            amPm = "am"
        } else if hour == 12 {
            timeHour = 12
            amPm = "pm"
        } else if hour > 12 && hour < 24{
            timeHour = hour - 12
            amPm = "pm"
        } else if hour == 24 {
            timeHour = 12
            amPm = "am"
        }
        let minuteStr = minute >= 10 ? "\(minute)": "0\(minute)"
        
        if timeHour > 0 && !amPm.isEmpty {
            return "\(timeHour):\(minuteStr)"+amPm
        } else {
            print("BarUtil: Error getting time paragraph \(timeHour) \(minuteStr) \(amPm)")
            return ""
        }
  
     

    }
}
