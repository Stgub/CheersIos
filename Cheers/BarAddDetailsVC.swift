//
//  BarDetailsVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

class BarAddDetailsVC: UIViewController, hasDataDict {
    var dataDict: [String : Any] = [:]
    @IBOutlet weak var barDescriptTextView: UITextView!
    
    @IBOutlet weak var barImgView: UIImageView!
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func editBarImgBtnTapped(_ sender: Any) {
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        dataDict[Bar.dataTypes.img] = self.barImgView.image
        dataDict[Bar.dataTypes.description] = self.barDescriptTextView.text
        self.performSegue(withIdentifier: "nextBarSignUpSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected object to the new view controller.
        let destVC = segue.destination
        switch(destVC){
        case is hasDataDict:
            var dest = destVC as! hasDataDict
            dest.dataDict = self.dataDict
        default:
            print("Default segue")
        }
    }
    

}
