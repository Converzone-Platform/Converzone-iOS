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
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
            
        case 0:
            
            cell?.textLabel?.text = "Goga"
            cell?.detailTextLabel?.text = "jknafdslkjas"
            
            cell?.imageView?.image = UIImage(named: "2")
            cell?.imageView?.layer.cornerRadius = cell?.imageView?.layer.frame.height ?? 50 / 2
            cell?.imageView?.layer.masksToBounds = true
            
            cell?.accessoryType = .disclosureIndicator
            
        default:
            
            //cell?.imageView?.image = UIImage(named: "austria")
            
            cell?.textLabel?.text = settings[ tableView.globalIndexPath(for: indexPath as NSIndexPath) ]
            
            cell?.accessoryType = .disclosureIndicator
            
        }
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        switch (indexPath.section){
        case 0:
            return 100
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
}
