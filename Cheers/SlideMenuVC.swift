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
struct MenuItem{
    var title:String
    var storyboardID:String
    var storyboard:String
}

class SlideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: SlideMenuDelegate?
    var menuItems:[MenuItem] =  [
        MenuItem(title: "Bar Feed", storyboardID: "BarFeedVC", storyboard: myStoryboards.main),
        MenuItem(title: "History", storyboardID: "HistoryVC", storyboard: myStoryboards.main),
        MenuItem(title: "Account", storyboardID: "AccountVC", storyboard: myStoryboards.main),
        MenuItem(title: "Contact Us", storyboardID: "ContactUsVC", storyboard: myStoryboards.main),
        MenuItem(title: "Refer a friend", storyboardID: "ReferralVC", storyboard: myStoryboards.main),
        MenuItem(title: "Sign Out", storyboardID: "FirstLoginVC", storyboard: myStoryboards.logOrSignIn)
    ]
    
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func closeMenuBtnTapped(_ sender: Any) {
        slideMenuAway()
    }

    func menuItemClicked( menuItem :MenuItem ){
        if (self.delegate != nil) {
            delegate?.slideMenuItemSelected(menuItem)
        }
        slideMenuAway()
    }
    
    func slideMenuAway(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItem") as! MenuItemTableViewCell
        cell.setMenuItem(menuItem: menuItems[indexPath.row])
        return cell
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
