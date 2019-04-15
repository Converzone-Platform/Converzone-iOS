//
//  ChatSettingsVC.swift
//  converzone
//
//  Created by Goga Barabadze on 04.04.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class ChatSettingsVC: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = master?.chats[indexOfUser].fullname
    }
}
