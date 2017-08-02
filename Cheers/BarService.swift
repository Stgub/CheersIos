//
//  BarService.swift
//  Cheers
//
//  Created by Charles Fayal on 6/29/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation

protocol BarServiceObserver{
    func updatedBars()
}
//TODO set up notifications
class BarService {
    struct WeekDay {
        var bars:[String] = []
    }
    var observer:BarServiceObserver!
    static let sharedService = BarService()

    init(){
        self.getBars()
    }
    private var bars:[String:Bar] = [:]
    private var barsPerWeek:[weekDays:WeekDay] = [.Monday:WeekDay(),
                                                  .Tuesday:WeekDay(),
                                                  .Wednesday:WeekDay(),
                                                  .Thursday:WeekDay(),
                                                  .Friday:WeekDay(),
                                                  .Saturday:WeekDay(),
                                                  .Sunday:WeekDay() ]
    func addObserver(observer:BarServiceObserver){
        self.observer = observer
    }
    func removeObserver(observer:BarServiceObserver){
        self.observer = nil
    }
    
    func isBarAvailable(key:String) -> Bool {
        guard let currentUser = UserService.sharedService.getCurrentUser() else {
            print("no current user")
            return false
        }
        
        if currentUser.barsUsed.keys.contains(key){
            if let timeIntUsed = currentUser.barsUsed[key] {
                let dateUsed = Date(timeIntervalSince1970: timeIntUsed)
                if dateUsed.timeIntervalSinceNow  > -60 * 60 * 24 { //used less than a day ago
                    return false
                    
                }
            }
        }
        return true
    }
        
    func getBars(){
        MyFireBaseAPIClient.sharedClient.getBars(){
            (returnedBars) in
            print("Backend API returned bars")
            for bar in returnedBars{
                
                if let _ = self.bars[bar.key] {
                    //Already have bar do nothing
                } else {
                    //New Bar
                    self.bars[bar.key] = bar
                    self.addBarToDaysAvailable(bar: bar)
                    if self.observer != nil {
                        self.observer.updatedBars()
                    }
                }
            }
        }
    }

    func getBars(forDay:weekDays) -> [String]{
        return barsPerWeek[forDay]?.bars ?? []
    }
    
    func getBar(id:String) -> Bar? {
        return self.bars[id]
    }
    
    func addBarToDaysAvailable(bar:Bar){
        let availableDays = bar.availableDays
        for day in weekDays.allDays {
            if let isAvailable = availableDays[day.toString]{
                if isAvailable{
                    barsPerWeek[day]!.bars.append(bar.key)
                }
            }
        }

    }
}


