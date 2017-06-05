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
    func slideMenuItemSelectedAtIndex(_ index: Int)
}

class SlideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: SlideMenuDelegate?
    var menuItems =  ["Bar Feed","History","Account"]
    
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func closeMenuBtnTapped(_ sender: Any) {
        slideMenuAway()
    }

    func menuItemClicked( index:Int ){        
        if (self.delegate != nil) {
            delegate?.slideMenuItemSelectedAtIndex(index)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuItem")!
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate == nil {
            print("No delegate for slide menu")
        } else {
            menuItemClicked(index: indexPath.row)
        }
    }

    
}
