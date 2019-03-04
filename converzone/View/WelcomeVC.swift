//
//  WelcomeVC.swift
//  converzone
//
//  Created by Goga Barabadze on 13.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {
    
    @IBOutlet weak var circle: UIImageView!
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var journeyOutlet: UIButton!
    @IBOutlet weak var blur: UIView!
    
    @IBAction func journeyAction(_ sender: Any) {
        
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseInOut, animations: {
            
            self.circle.layer.position.y = self.view.frame.height + self.circle.frame.width
            self.blur.alpha = 0
            self.journeyOutlet.alpha = 0
            self.welcomeMessage.alpha = 0
            
        }, completion: { (bool) in
            self.welcomeMessage.text = "Have fun :)"
            self.welcomeMessage.layer.position.y = self.view.frame.height / 2
        })
        
        UIView.animate(withDuration: 2, delay: 2, options: .curveEaseInOut, animations: {
            
            self.welcomeMessage.alpha = 1
            
        }){ (bool) in
        
            print("All animations are finished")
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        circle.layer.cornerRadius = circle.layer.frame.width / 2
        circle.layer.masksToBounds = true
        
        journeyOutlet.layer.cornerRadius = 15
        journeyOutlet.layer.masksToBounds = true
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
}
