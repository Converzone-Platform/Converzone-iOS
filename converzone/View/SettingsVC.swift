//
//  SettingsVC.swift
//  converzone
//
//  Created by Goga Barabadze on 18.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

var settings = ["Profile", "Only for pros", "Account", "Notifications", "Security", "Languages", "Network", "Help", "Recommend to your best friend", "Sign off"]

class SettingsVC: UIViewController {
    
    
    
}

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsFor(section: section)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")
        
        cell?.imageView?.image = UIImage(named: "austria")
        
        cell?.textLabel?.text = settings[ rowsFor(section: indexPath.section) + indexPath.row - 1 ]
        
        return cell!
    }
    
    func rowsFor(section: Int) -> Int{
        
        switch (section){
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 5
        case 3:
            return 2
        case 4:
            return 1
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
