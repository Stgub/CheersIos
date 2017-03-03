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
        static let location = "Location"
        static let imgUrl = "ImgUrl"
        static let barName = "barName"
    }
    var key:String!
    var barName:String!
    var location:String!
    var img:UIImage!
    var imgUrl:String!
    
    init(barKey:String, dataDict:Dictionary<String,AnyObject>){
        self.key = barKey
        if let barName = dataDict[dataTypes.barName] as? String {
            self.barName = barName
        }
        if let location = dataDict[dataTypes.location] as? String{
            self.location = location
        }
        if let imgUrl = dataDict[Bar.dataTypes.imgUrl] as? String{
            self.imgUrl = imgUrl
 
        }

    }
    func getImage(returnBlock:@escaping ()->()){
        let ref = FIRStorage.storage().reference(forURL: self.imgUrl)
        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("Chuck: Error downloading img -\(error)")
                
            } else {
                print("Chuck: Img downloaded from Firebase storage")
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                            self.img = img
                            returnBlock()
                    } else { print("Could not load image from data")}
                }
            }
        })
    }
    
 

}
