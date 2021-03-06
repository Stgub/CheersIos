//
//  Bar.swift
//  Cheers
//
//  Created by Charles Fayal on 2/28/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase

struct dealTypes {
    static let oneFreeDrink = "oneFreeDrink"
    static let buyOneGetOne = "buyOneGetOne"
    static let halfOffBottle = "halfOffBottle"
    static let freeApp = "freeApp"
}

class Bar {
    struct dataTypes{
        static let img = "img"
        static let imgUrl = "ImgUrl"
        static let barName = "barName"
        static let description = "description"
        static let shortDescription = "shortDescription"
        static let locationStreet = "locationStreet"
        static let locationCity = "locationCity"
        static let locationState = "locationState"
        static let locationZipCode = "locationZipCode"
        static let phoneNumber = "phoneNumber"
        static let deals = "deals"
        static let drinks = "drinks"
        static let hoursOpen = "hoursOpen"
        static let availableDays = "availableDays"
    }
    var refFB:DatabaseReference!
    var key:String!
    var barName:String!
    var locationStreet:String!
    var locationCity:String!
    var locationState:String!
    var locationZipCode:String!
    var phoneNumber:String!
    var img:UIImage!
    var imgUrl:String!
    var description:String!
    var shortDescription:String!
    var drinks: String!
    var hoursOpen: Dictionary<String,Int>!
    var availableDays:[String:Bool] = [:] //contains a string for each day of the week that it is available e.g. Monday, Tuesday
    var deals:[String:String] = [:]
    
    init(barKey:String, dataDict:Dictionary<String,AnyObject>){
        self.key = barKey
        self.refFB = DataService.ds.REF_BARS.child(self.key) // This will change if we put the bars in more complex data architects
        if let barName = dataDict[dataTypes.barName] as? String {
            self.barName = barName
        }
        if let locationStreet = dataDict[dataTypes.locationStreet] as? String{
            self.locationStreet = locationStreet
        }
        if let locationCity = dataDict[dataTypes.locationCity] as? String{
            self.locationCity = locationCity
        }
        if let locationState = dataDict[dataTypes.locationState] as? String{
            self.locationState = locationState
        }
        if let locationZipCode = dataDict[dataTypes.locationZipCode] as? String{
            self.locationZipCode = locationZipCode
        }
        if let phoneNumber = dataDict[dataTypes.phoneNumber] as? String{
            self.phoneNumber = phoneNumber
        }
        if let description = dataDict[dataTypes.description] as? String{
            self.description = description
        }
        if let shortDescript = dataDict[dataTypes.shortDescription] as? String{
            self.shortDescription = shortDescript
        }
        if let drinks = dataDict[dataTypes.drinks] as? String{
            self.drinks = drinks
        }
        if let imgUrl = dataDict[dataTypes.imgUrl] as? String{
            self.imgUrl = imgUrl
        }
        if let hoursOpen = dataDict[dataTypes.hoursOpen]{
            if let hoursOpen = hoursOpen as? Dictionary<String,Int>{
                self.hoursOpen = hoursOpen
            } else {print("Bar:\(barName) hoursOpen could not cast to dict")}
        } else { print("Bar:\(barName) no hours found")}
        if let availableDays = dataDict[dataTypes.availableDays] as? [String:Bool]{
            self.availableDays = availableDays
            
        } else { print("**** Couldn't add bar available days" )}
        if let deals = dataDict[dataTypes.deals] as? [String:String]{
            self.deals = deals
        } else { print("Bar:\(barName) no deals or could not cast")}
    }
    
    func getImage(returnBlock:@escaping ()->()){
        //print("Getting image for \(self.barName)")
        guard let imageUrl = self.imgUrl else {
            print("CHUCK: no image url")
            return
        }
        if let image = imageCache.object(forKey: imageUrl as NSString) {
            //print("Image from cache \(self.barName)")
            self.img = image
            returnBlock()
        } else {
            //print("Image from database \(self.barName)")
            let ref = Storage.storage().reference(forURL: imageUrl)
            
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("Error: loading bar image -\(String(describing: error))")
                    
                } else {
                    //print("Chuck: Img downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                                imageCache.setObject(img, forKey: self.imgUrl as NSString)
                                self.img = img
                                returnBlock()
                        } else { print("Error: Could not load bar image from data")}
                    }
                }
            })
        }
    }
    
    func setImage(imageView: UIImageView){
        getImage {
            imageView.image = self.img
        }
    }

 

}

/*
 func to add days to bars
 for bar in self.bars.values{
 let daysavail = [
 weekDays.Monday.toString:true,
 weekDays.Tuesday.toString:true,
 weekDays.Wednesday.toString:true,
 weekDays.Thursday.toString:true,
 weekDays.Friday.toString:true,
 weekDays.Saturday.toString:true,
 weekDays.Sunday.toString:true
 ]
 bar.refFB.child(Bar.dataTypes.availableDays).setValue(daysavail)

 */

