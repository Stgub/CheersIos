//
//  AccountVC.swift
//  Cheers
//
//  Created by Charles Fayal on 2/27/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class AccountVC: BaseMenuVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var imagePicker = UIImagePickerController()

    @IBOutlet weak var profileImg: circlePP!
    
    @IBAction func editPicBtnTapped(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)

    }
    
    @IBOutlet weak var leftMenuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachMenuButton(menuButton: leftMenuButton)
        if let user = currentUser{
            user.getUserImg(returnBlock: { (img) in
                self.profileImg.image = img
            })
        }
    }

    
    //MARK: - Delegates
    // In order to work you need to put in a photo access description in Plist. Need to add one for camera if we wish to add
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        profileImg.image = chosenImage //4
        currentUser.usersImage = chosenImage
        currentUser.saveUserImg(img: chosenImage)
        dismiss(animated:true, completion: nil) //5
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func logOutBtnTapped(_ sender: Any) {
        print("Log out btn tapped")
        UserService.shareService.signOut()
        presentFirstLoginVC(sender:self)

        
    }



}
