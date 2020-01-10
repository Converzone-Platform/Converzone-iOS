//
//  LoginVC.swift
//  converzone
//
//  Created by Goga Barabadze on 26.10.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import WebKit
import os

var master: Master = Master()

class SplashScreenVC: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var welcome_text_label: UILabel!
    
    @IBOutlet weak var continue_button_outlet: UIButton!
    
    @IBOutlet weak var flag_globe_webview: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderWelcomeMessage()
        
        flag_globe_webview.navigationDelegate = self
        
    }
    
    override func viewWillLayoutSubviews() {
        setUpWebKit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Internet.signOut()
        
        master.editingMode = .registration
        
        master = Master()
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        animateGlobe()
    }
    
    /// Animate globe alpha to 100% when the SplashScreen is loaded
    private func animateGlobe(){
        
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseInOut, animations: {
            self.flag_globe_webview.alpha = 1
        }, completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        flag_globe_webview.alpha = 0
    }
    
    private func setUpWebKit(){
        
        guard let path = Bundle.main.path(forResource: "index", ofType: "html") else {
            os_log("Could not load index.html file")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let request = URLRequest(url: url)
        
        flag_globe_webview.navigationDelegate = self
        
        flag_globe_webview.load(request)
    }
    
   /**
     Message is displayed on the welcome screen and is meant to be in English for every user
     */
    private func renderWelcomeMessage(){
        let attributedString = NSMutableAttributedString(string: "Chat with the world.")
        
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: Colors.blue
        ]
        attributedString.addAttributes(attributes, range: NSRange(location: 10, length: 9))
        
        welcome_text_label.attributedText = attributedString
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Close keyboard when touched somewhere else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
