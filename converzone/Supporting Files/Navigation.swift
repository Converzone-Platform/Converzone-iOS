//
//  Navigation.swift
//  converzone
//
//  Created by Goga Barabadze on 14.09.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class Navigation {
    
    static func push(viewController: String, context: UIViewController){
        context.navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController), animated: true)
    }
    
    static func present(controller: String, context: UIViewController){
        context.present((context.storyboard?.instantiateViewController(withIdentifier: controller))!, animated: true, completion: nil)
    }
    
    static func pop(context: UIViewController){
        context.navigationController?.popViewController(animated: true)
    }
    
    static func change(navigationController: String){
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: navigationController)
    }
    
}
