//
//  MainTBC.swift
//  converzone
//
//  Created by Goga Barabadze on 03.11.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class MainTBC: UITabBarController {

    @IBOutlet weak var tab_bar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            
            let configuration = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
            
            tab_bar.items?[0].image = UIImage(systemName: "ellipses.bubble", withConfiguration: configuration)
            tab_bar.items?[1].image = UIImage(systemName: "globe", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium))
            tab_bar.items?[2].image = UIImage(systemName: "rectangle.stack.person.crop", withConfiguration: configuration)
            
        }else{
            
            tab_bar.items?[0].image = UIImage(named: "chat_nav")
            tab_bar.items?[1].image = UIImage(named: "web_nav")
            tab_bar.items?[2].image = UIImage(named: "discover_nav")
            
        }
    }
}
