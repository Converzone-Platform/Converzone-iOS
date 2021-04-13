//
//  UserProtection.swift
//  converzone
//
//  Created by Goga Barabadze on 07.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import UIKit
import SwiftAlert

class UserProtection {
    
    private static let context = UIApplication.currentViewController()
    
    @objc static func displayBlockAndReport(){
        
        let actions = [
        
            UIAlertAction(title: "Report", style: .destructive) { (action) in
                
                UserProtection.self.report(title: "Report user", message: "Tell us why you want to report this user.")
            },
            
            UIAlertAction(title: "Block", style: .destructive, handler: { (aler_action) in
                Internet.block(userid: profile_of.uid)
            }),
            
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
        ]
        
        Alert.alert(title: "What do you want to do?", message: "Please help us make our platform a little better.", actions: actions)
    }
    
    static func report(title: String, message: String) {
        
        var saveTextField: UITextField? = nil
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.context?.view
            popoverController.sourceRect = CGRect(x: (self.context?.view.bounds.midX)!, y: self.context!.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        let action = UIAlertAction(title: "Send", style: .default) { (alertAction) in
            
            saveTextField = alert.textFields![0] as UITextField
            
            guard let text = saveTextField?.text else {
                return
            }
            
            Internet.report(userid: profile_of.uid, reason: text)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Describe what's wrong"
            saveTextField = textField
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(action)
        UIApplication.currentViewController()?.present(alert, animated:true, completion: nil)
        
    }
}
