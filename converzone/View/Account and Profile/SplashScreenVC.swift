//
//  LoginVC.swift
//  converzone
//
//  Created by Goga Barabadze on 26.10.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import WebKit

var master: Master = Master()

class SplashScreenVC: NoAutoRotateViewController, WKUIDelegate {
    
    @IBOutlet weak var welcome_label: UILabel!
    @IBOutlet weak var continue_outlet: UIButton!
    @IBOutlet weak var terms_of_service_outlet: UIButton!
    
    @IBOutlet weak var globe_view: WKWebView!
    
    
    @IBAction func terms_of_service_button(_ sender: Any) {
        // MARK: TODO - Implement a view which shows the current terms of service
    }
    
    @IBAction func continue_button(_ sender: Any) {
        
        Navigation.change(navigationController: "PhoneVerificationNC")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderWelcomeMessage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        master.changingData = .registration
        
        setUpWebKit()
    }
    
    private func setUpWebKit(){
        
        let path = Bundle.main.path(forResource: "index", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        
        globe_view.load(request)
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
        
        welcome_label.attributedText = attributedString
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //Close keyboard when touched somewhere else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
