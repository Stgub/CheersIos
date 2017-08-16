//
//  SlideMenuVC.swift
//  Cheers
//
//  Created by Charles Fayal on 6/1/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit

//ContainerViewController

protocol SlideMenuDelegate {
    func slideMenuItemSelected(_ menuItem: MenuItem)
}
protocol  Menu {
    func closeMenu()
    func openMenu(superView:UIView)
}
struct MenuItem{
    var title:String
    var storyboardID:String
    var storyboard:String
}


class SlideMenuVC: UIViewController, Menu, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: SlideMenuDelegate?
    var menuItems:[MenuItem] =  [
        MenuItem(title: "Venues", storyboardID: "BarFeedVC", storyboard: myStoryboards.main),
        MenuItem(title: "History", storyboardID: "HistoryVC", storyboard: myStoryboards.main),
        MenuItem(title: "Account", storyboardID: "AccountVC", storyboard: myStoryboards.main),
        MenuItem(title: "Contact Us", storyboardID: "ContactUsVC", storyboard: myStoryboards.main),
       // MenuItem(title: "Refer a friend", storyboardID: "ReferralVC", storyboard: myStoryboards.main),
        MenuItem(title: "Recommend a Business", storyboardID: "RecommendBarVC", storyboard: myStoryboards.main),
        MenuItem(title: "FAQ", storyboardID: "FAQVC", storyboard: myStoryboards.main),
 
    ]
    @IBAction func privacyPolicyBtnTapped(_ sender: Any) {
        let item = MenuItem(title: "Privacy Policy", storyboardID: "PrivacyPolicyVC", storyboard: myStoryboards.main)
        self.menuItemClicked(menuItem: item)
    }
    
    @IBAction func termsBtnTapped(_ sender: Any) {
        let item = MenuItem(title: "Terms and Conditions", storyboardID: "TermsAndConditionsVC", storyboard: myStoryboards.main)
        self.menuItemClicked(menuItem: item)
    }
    
    @IBAction func signOutBtnTapped(_ sender: Any) {
        let item =  MenuItem(title: "Sign Out", storyboardID: "signout", storyboard: "signout")
        self.menuItemClicked(menuItem: item)
    }
    
    
    @IBOutlet weak var btnMenu: UIButton!

    @IBOutlet weak var tableView: UITableView!
    
    var menuBlankSpaceView:UIButton!
    @IBAction func closeMenuBtnTapped(_ sender: Any) {
        closeMenu()
    }
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView() // get rid of extra rows

        let swipeLeft = UISwipeGestureRecognizer(target: self, action:#selector(self.closeMenu))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func menuItemClicked( menuItem :MenuItem ){
        if (self.delegate != nil) {
            delegate?.slideMenuItemSelected(menuItem)
        }
        closeMenu()
    }
    
    func closeMenu(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            let screenWidth = UIScreen.main.bounds.size.width
            let screenHeight =  UIScreen.main.bounds.size.height
            
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: screenWidth,height: screenHeight)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            if self.menuBlankSpaceView != nil {
                self.menuBlankSpaceView.frame = CGRect(x: 0, y:0, width: screenWidth, height: screenHeight)
            }
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            if self.menuBlankSpaceView != nil {
                self.menuBlankSpaceView.removeFromSuperview()
            }
        })
    }
    func openMenu(superView:UIView){
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight =  UIScreen.main.bounds.size.height
        let menuWidth = screenWidth * 4/5
        
        
        //setting up screen to take up blank space. Also when tapped will close menu
        menuBlankSpaceView = UIButton(frame: CGRect(x: 0, y:0, width: screenWidth, height: screenHeight))
        menuBlankSpaceView.backgroundColor = UIColor.lightGray
        menuBlankSpaceView.alpha = 0.3
        menuBlankSpaceView.addTarget(self, action: #selector(self.closeMenu), for: UIControlEvents.touchUpInside)
        superView.addSubview(menuBlankSpaceView)
        
        self.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: menuWidth, height: screenHeight); //Beginning position

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame=CGRect(x: 0, y: 0, width: menuWidth, height: UIScreen.main.bounds.size.height) // final posittion
            self.menuBlankSpaceView.frame = CGRect(x: menuWidth, y:0, width: screenWidth, height: screenHeight)
        }, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItem") as! MenuItemTableViewCell
        cell.setMenuItem(menuItem: menuItems[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MenuItemTableViewCell
        if delegate == nil {
            print("No delegate for slide menu")
        } else {
            menuItemClicked(menuItem: cell.menuItem )
        }
    }

    
}
