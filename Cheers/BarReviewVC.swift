//
//  BarReviewVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase

class BarReviewVC: UIViewController, hasDataDict {
    var dataDict: [String : Any] = [:]
    var firebaseDict:[String:AnyObject] = [:]
    @IBOutlet weak var barNameLabel: UILabel!
    
    @IBOutlet weak var barDescriptLabel: UILabel!
    @IBOutlet weak var barImgView: RoundedImageCorner!
    @IBOutlet weak var barStreetLabel: UILabel!
    @IBOutlet weak var barAreaLabel: UILabel!
    @IBOutlet weak var barHoursLabel: UILabel!
    @IBOutlet weak var barPhoneNumberLabel: UILabel!
    @IBOutlet weak var drinksLabel: UILabel!

    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func submitBtnTapped(_ sender: Any) {
        
        let firebasePost = DataService.ds.REF_BARS.childByAutoId()
        //let postId = firebasePost.key
        firebasePost.setValue(firebaseDict) { (error, ref) in
            if error == nil {
                presentUIAlert(sender: self, title: "", message: "Success!")
            } else {
                print("Chuck: Error -\(error)")
                presentUIAlert(sender: self, title: "Error", message: "\(error.debugDescription)")
            }
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let barName = dataDict[Bar.dataTypes.barName] as? String {
            self.barNameLabel.text = barName
            firebaseDict[Bar.dataTypes.barName] = barName as AnyObject
        }
        if let locationStreet = dataDict[Bar.dataTypes.locationStreet] as? String{
            self.barStreetLabel.text = locationStreet
            firebaseDict[Bar.dataTypes.locationStreet] = locationStreet as AnyObject
        }
        var areaString = ""
        if let locationCity = dataDict[Bar.dataTypes.locationCity] as? String{
            areaString += locationCity
            firebaseDict[Bar.dataTypes.locationCity] = locationCity as AnyObject
        }
        if let locationState = dataDict[Bar.dataTypes.locationState] as? String{
            areaString += ", \(locationState)"
            firebaseDict[Bar.dataTypes.locationState]  = locationState as AnyObject
        }
        if let locationZipCode = dataDict[Bar.dataTypes.locationZipCode] as? String{
            areaString += " \(locationZipCode)"
            firebaseDict[Bar.dataTypes.locationZipCode] = locationZipCode as AnyObject
        }
        barAreaLabel.text = areaString
        if let phoneNumber = dataDict[Bar.dataTypes.phoneNumber] as? String{
            self.barPhoneNumberLabel.text = phoneNumber
            firebaseDict[Bar.dataTypes.phoneNumber] = phoneNumber as AnyObject

        }
        if let description = dataDict[Bar.dataTypes.description] as? String{
            self.barDescriptLabel.text = description
            firebaseDict[Bar.dataTypes.description] = description as AnyObject

        }
        if let drinks = dataDict[Bar.dataTypes.drinks] as? String{
            self.drinksLabel.text = drinks
            firebaseDict[Bar.dataTypes.drinks] = drinks as AnyObject
        }
        if let image = dataDict[Bar.dataTypes.img] as? UIImage {
            self.barImgView.image = image
            postBarImage(barImage: image ) {
                (imgUrl) in
                self.firebaseDict[Bar.dataTypes.imgUrl] = imgUrl as AnyObject
                
            }
        }
 
    }
    
    func postBarImage(barImage:UIImage, returnBlock:@escaping (_ imgUrl:String)->()){
        
        if let productImgData = UIImageJPEGRepresentation(barImage, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_BAR_IMAGES.child(imgUid).put(productImgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Chuck: Unable to upload image to Firebasee storage - \(error)")
                } else {
                    print("Chuck: Successfully uploaded image to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        returnBlock(url)
                    }
                }
            }
        }
    }
    



}
