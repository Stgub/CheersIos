//
//  BaseMenuVC.swift
//  Cheers
//
//  Created by Charles Fayal on 6/2/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit
// Reference website
// https://github.com/ashishkakkad8/AKSwiftSlideMenu/tree/master/AKSwiftSlideMenu
class BaseMenuVC: UIViewController, SlideMenuDelegate {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        switch(index){
        case 0:
            print("BarFeed\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("BarFeedVC")
            
            break
        case 1:
            print("HistoryVC\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("HistoryVC")
            
            break
        case 2:
            print("Account\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("AccountVC")
            
            break
        default:
            print("Default index for slide menu?")
            print("BarFeed\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("BarFeedVC")
            
            break
        }
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func attachMenuButton(menuButton: UIButton){
        menuButton.addTarget(self, action: #selector(BaseMenuVC.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
    }
    /*
    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    } */
    
    func onSlideMenuButtonPressed(_ sender : UIButton){
        print("slideMenuButtonPresseD")
        //there was code here to close the menu if the show menu button was double clicked but I dont think it is necessary
        let menuVC : SlideMenuVC = self.storyboard!.instantiateViewController(withIdentifier: "LeftMenuVC") as! SlideMenuVC
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        let menuWidth = UIScreen.main.bounds.size.width - 30
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: menuWidth, height: UIScreen.main.bounds.size.height); //necessary or it goes to end then back?
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
           menuVC.view.frame=CGRect(x: 0, y: 0, width: menuWidth, height: UIScreen.main.bounds.size.height); // final width
            sender.isEnabled = true
        }, completion:nil)
    }
}
