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
        var swipeRight = UISwipeGestureRecognizer(target: self, action:#selector(self.openLeftMenu))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func slideMenuItemSelected(_ menuItem: MenuItem)
    {
        let navigationController = self.navigationController!
        let topViewController : UIViewController = navigationController.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        
        if menuItem.storyboardID == "signout" {
            UserService.shareService.signOut()
            GeneralFunctions.presentFirstLoginVC(sender: self)
            return
        }
        
        let storyboard = UIStoryboard(name: menuItem.storyboard, bundle: Bundle.main)
        let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: menuItem.storyboardID)
        
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    

    func attachMenuButton(menuButton: UIButton){
        menuButton.addTarget(self, action: #selector(BaseMenuVC.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
    }

    
    func onSlideMenuButtonPressed(_ sender : UIButton){
        print("onSlideMenuButtonPressed")
        //there was code here to close the menu if the show menu button was double clicked but I dont think it is necessary
        openLeftMenu()
    }
    func openLeftMenu(){
        let storyboard:UIStoryboard =  UIStoryboard(name: myStoryboards.menu, bundle: Bundle.main)
        let menuVC : SlideMenuVC = storyboard.instantiateViewController(withIdentifier: "LeftMenuVC") as! SlideMenuVC
        //menuVC.btnMenu = self
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        menuVC.openMenu(superView: self.view)
    }
}
