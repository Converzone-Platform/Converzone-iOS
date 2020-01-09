//
//  Alerts.swift
//  converzone
//
//  Created by Goga Barabadze on 29.05.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

func alert(_ title: String, _ message: String, _ target: UIViewController = UIApplication.currentViewController()!, closure: (() -> Void)? = nil){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    if let popoverController = alert.popoverPresentationController {
        popoverController.sourceView = target.view // to set the source of your alert
        popoverController.sourceRect = CGRect(x: target.view.bounds.midX, y: target.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
        popoverController.permittedArrowDirections = []
    }
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
        
        guard let closure = closure else {
            return
        }
        
        closure()
        
    }))
    
    target.present(alert, animated: true, completion: nil)
}
