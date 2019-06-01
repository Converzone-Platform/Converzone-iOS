//
//  Alerts.swift
//  converzone
//
//  Created by Goga Barabadze on 29.05.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

func alert(_ title: String, _ message: String, _ target: UIViewController){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    target.present(alert, animated: true, completion: nil)
    
}
