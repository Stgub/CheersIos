//
//  BarHoursVC.swift
//  Cheers
//
//  Created by Charles Fayal on 3/7/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit


class BarHoursVC: UIViewController, hasDataDict {
    var dataDict = [String:Any]()
    @IBOutlet var amPmBtns: [UIButton]!
    @IBOutlet var timeFields: [UITextField]!
    
    @IBOutlet weak var monOpen: UITextField!
    @IBOutlet weak var tueOpen: UITextField!
    @IBOutlet weak var wedOpen: UITextField!
    @IBOutlet weak var thurOpen: UITextField!
    @IBOutlet weak var friOpen: UITextField!
    @IBOutlet weak var satOpen: UITextField!
    @IBOutlet weak var sunOpen: UITextField!
    @IBOutlet weak var monClose: UITextField!
    @IBOutlet weak var tueClose: UITextField!
    @IBOutlet weak var wedClose: UITextField!
    @IBOutlet weak var thurClose: UITextField!
    @IBOutlet weak var friClose: UITextField!
    @IBOutlet weak var satClose: UITextField!
    @IBOutlet weak var sunClose: UITextField!
    
    @IBOutlet weak var monOpenBtn: UIButton!
    @IBOutlet weak var tueOpenBtn: UIButton!
    @IBOutlet weak var wedOpenBtn: UIButton!
    @IBOutlet weak var thurOpenBtn: UIButton!
    @IBOutlet weak var friOpenBtn: UIButton!
    @IBOutlet weak var satOpenBtn: UIButton!
    @IBOutlet weak var sunOpenBtn: UIButton!
    @IBOutlet weak var monCloseBtn: UIButton!
    @IBOutlet weak var tueCloseBtn: UIButton!
    @IBOutlet weak var wedCloseBtn: UIButton!
    @IBOutlet weak var thuCloseBtn: UIButton!
    @IBOutlet weak var friCloseBtn: UIButton!
    
    @IBOutlet weak var satCloseBtn: UIButton!
    
    @IBOutlet weak var sunCloseBtn: UIButton!
    
    
    
    @IBOutlet weak var drinksTextView: UITextView!
    
    @IBAction func autofillBtnTapped(_ sender: Any) {
        tueOpen.text = monOpen.text!
        wedOpen.text = monOpen.text!
        thurOpen.text = monOpen.text!
        friOpen.text = monOpen.text!
        satOpen.text = monOpen.text!
        sunOpen.text = monOpen.text!

        tueClose.text = monClose.text!
        wedClose.text = monClose.text!
        thurClose.text = monClose.text!
        friClose.text = monClose.text!
        satClose.text = monClose.text!
        sunClose.text = monClose.text!
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    var barHours = ""
    @IBAction func nextBtnTapped(_ sender: Any) {
    barHours = "Mon. \(monOpen.text!)\(monOpenBtn.titleLabel!.text!)-\(monClose.text!)\(monCloseBtn.titleLabel!.text!)"
    barHours += ", "
    barHours += "Tue. \(tueOpen.text!)\(tueOpenBtn.titleLabel!.text!)-\(tueClose.text!)\(tueCloseBtn.titleLabel!.text!)"
    barHours += ", "
    barHours += "Wed. \(wedOpen.text!)\(wedOpenBtn.titleLabel!.text!)-\(wedClose.text!)\(wedCloseBtn.titleLabel!.text!)"
    barHours += ", "
    barHours += "Thur. \(thurOpen.text!)\(thurOpenBtn.titleLabel!.text!)-\(thurClose.text!)\(thuCloseBtn.titleLabel!.text!)"
    barHours += ", "
    barHours += "Fri. \(friOpen.text!)\(friOpenBtn.titleLabel!.text!)-\(friClose.text!)\(friCloseBtn.titleLabel!.text!)"
    barHours += ", "
    barHours += "Sat. \(satOpen.text!)\(satOpenBtn.titleLabel!.text!)-\(satClose.text!)\(satCloseBtn.titleLabel!.text!)"
    barHours += ", "
    barHours += "Sun. \(sunOpen.text!)\(sunOpenBtn.titleLabel!.text!)-\(sunClose.text!)\(sunCloseBtn.titleLabel!.text!)"
        
        var periodDict:[String:String] = [:]
        var hoursDict:[String:String] = [:]
        for button in amPmBtns{
            periodDict[button.accessibilityIdentifier!] = button.titleLabel!.text!
        }
        for time in timeFields{
            hoursDict[time.accessibilityIdentifier!] = time.text!
        }
        dataDict["hoursDict"] = hoursDict
        dataDict["periodDict"] = periodDict
        dataDict["drinks"] = drinksTextView.text!

        self.performSegue(withIdentifier: "nextBarSignUpSegue", sender: self)
    }
    @IBAction func amPmBtnTapped(_ button :UIButton){
        if button.titleLabel!.text! == "am"{
            button.setTitle("pm", for: .normal)
        } else {
            button.setTitle("am", for: .normal )
        }
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