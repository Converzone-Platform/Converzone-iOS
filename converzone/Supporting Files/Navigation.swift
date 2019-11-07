//
//  Navigation.swift
//  converzone
//
//  Created by Goga Barabadze on 14.09.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import FirebaseAuth

class Navigation {
    
    static func push(viewController: String, context: UIViewController = UIApplication.currentViewController()!){
        context.navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController), animated: true)
    }
    
    static func present(controller: String, context: UIViewController = UIApplication.currentViewController()!){
        context.present((context.storyboard?.instantiateViewController(withIdentifier: controller))!, animated: true, completion: nil)
    }
    
    static func pop(context: UIViewController = UIApplication.currentViewController()!){
        context.navigationController?.popViewController(animated: true)
    }
    
    static func change(navigationController: String){
        
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: navigationController)
    }
    
    /// Is the user verified/logged in? If not, let's take them to the SplashScreen
    static func didnotFinishRegistration() -> Bool{
        
        if Auth.auth().currentUser == nil || UserDefaults.standard.bool(forKey: "DidFinishRegistration") == false {
            return true
        }
        
        return false
    }
}
