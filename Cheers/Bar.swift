//
//  Bar.swift
//  Cheers
//
//  Created by Charles Fayal on 2/28/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase

class Bar {
    struct dataTypes{
        static let imgUrl = "ImgUrl"
        static let barName = "barName"
        
        static let locationStreet = "LocationStreet"
        static let locationCity = "LocationCity"
        static let locationState = "LocationState"
        static let locationZipCode = "LocationZipCode"

    }
    var key:String!
    var barName:String!
    var locationStreet:String!
    var locationCity:String!
    var locationState:String!
    var locationZipCode:String!
    var img:UIImage!
    var imgUrl:String!
    var hasBeenUsed:Bool!
    
    init(barKey:String, dataDict:Dictionary<String,AnyObject>){
        self.key = barKey
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
        if let imgUrl = dataDict[Bar.dataTypes.imgUrl] as? String{
            self.imgUrl = imgUrl
 
        }

    }
    func getImage(returnBlock:@escaping ()->()){
        if let image = imageCache.object(forKey: self.imgUrl as NSString) {
            self.img = image
            returnBlock()
        } else {
            let ref = FIRStorage.storage().reference(forURL: self.imgUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("Chuck: Error downloading img -\(error)")
                    
                } else {
                    print("Chuck: Img downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                                imageCache.setObject(img, forKey: self.imgUrl as NSString)
                                self.img = img
                                returnBlock()
                        } else { print("Could not load image from data")}
                    }
                }
            })
        }
    }
    
 

}
