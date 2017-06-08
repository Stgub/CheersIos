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
    
    func slideMenuItemSelected(_ menuItem: MenuItem) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        let storyboard = UIStoryboard(name: menuItem.storyboard, bundle: Bundle.main)
        
        let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: menuItem.storyboardID)
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }    }
    

    func attachMenuButton(menuButton: UIButton){
        menuButton.addTarget(self, action: #selector(BaseMenuVC.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
    }

    
    func onSlideMenuButtonPressed(_ sender : UIButton){
        print("onSlideMenuButtonPressed")
        //there was code here to close the menu if the show menu button was double clicked but I dont think it is necessary
        let storyboard:UIStoryboard =  UIStoryboard(name: myStoryboards.menu, bundle: Bundle.main)
        let menuVC : SlideMenuVC = storyboard.instantiateViewController(withIdentifier: "LeftMenuVC") as! SlideMenuVC
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        menuVC.openMenu(superView: self.view)
      
    
    }
}
