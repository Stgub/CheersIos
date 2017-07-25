//
//  LoginBaseVC.swift
//  Cheers
//
//  Created by Charles Fayal on 7/24/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import UIKit


class AsyncControllerBase : UIViewController  {
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var asyncInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.asyncInProgress {
                    self.view.isUserInteractionEnabled = false
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                }
                else {
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                }
            }, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    func startAsyncProcess(){
        asyncInProgress = true
    }
    
    func stopAsyncProcess(){
        asyncInProgress = false
        
    }
    
    
}
