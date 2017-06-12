//
//  PaypalWebViewVC.swift
//  Cheers
//
//  Created by Charles Fayal on 6/11/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

// security settings https://makeapppie.com/2015/10/21/why-your-web-view-doesnt-work-in-ios9-and-what-to-do-about-it/
import UIKit

class PaypalWebViewVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        webView.loadRequest(URLRequest(url: URL(string: SERVER_BASE + "/subscribe")!))


        // Do any additional setup after loading the view.
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Failed to load webview - \(error.localizedDescription)")
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Started webview load")
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Finished webview load")
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("shouldStartLoadWith")
        print(request.url)
        let pathComponents = request.url?.pathComponents
        print("Path components - " + (pathComponents?.description)!)
        if(pathComponents?.contains("return"))!{
            self.dismiss(animated: true, completion: nil)
        }
        
        return true
    }
    
    

}
