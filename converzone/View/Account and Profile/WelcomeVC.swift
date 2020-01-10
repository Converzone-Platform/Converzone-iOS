//
//  WelcomeVC.swift
//  converzone
//
//  Created by Goga Barabadze on 13.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import CoreHaptics

class WelcomeVC: UIViewController {
    
    @IBOutlet weak var circle_imageView: UIImageView!
    @IBOutlet weak var welcomeMessage_label: UILabel!
    @IBOutlet weak var journey_outlet: UIButton!
    @IBOutlet weak var blur_view: UIView!
    
    @IBAction func journeyAction_button(_ sender: Any) {
        
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseInOut, animations: {
            
            self.circle_imageView.layer.position.y = self.view.frame.height + self.circle_imageView.frame.width
            self.blur_view.alpha = 0
            self.journey_outlet.alpha = 0
            self.welcomeMessage_label.alpha = 0
            self.circle_imageView.alpha = 0
            
        }, completion: { (bool) in
            self.welcomeMessage_label.text = "Have fun :)"
            self.welcomeMessage_label.layer.position.y = self.view.frame.height / 2
        })
        
        UIView.animate(withDuration: 2, delay: 2, options: .curveEaseInOut, animations: {
            
            self.welcomeMessage_label.alpha = 1
            
        }){ (bool) in
        
            master.editingMode = .editing
            
            UserDefaults.standard.set(true, forKey: "DidFinishRegistration")
            
            Internet.setUpListeners()
            
            Internet.upload(token: master.device_token)
            
            // Animate to actual app
            self.performSegue(withIdentifier: "showActualAppSegue", sender: nil)
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        circle_imageView.layer.cornerRadius = circle_imageView.layer.frame.width / 2
        circle_imageView.layer.masksToBounds = true
        
        journey_outlet.layer.cornerRadius = 15
        journey_outlet.layer.masksToBounds = true
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
