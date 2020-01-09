//
//  ReminderVC.swift
//  converzone
//
//  Created by Goga Barabadze on 15.12.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class ReminderVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @objc func switchStateChanged(sender:UISwitch!) {

        if sender.isOn {

            LocalNotification.scheduleNotification(title: "Keep your hard work up!")

        }else{
            
            LocalNotification.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["ReminderNotification"])
            
        }
        
        UserDefaults.standard.set(sender.isOn, forKey: "ReminderNotification")

    }
}

extension ReminderVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BooleanInputCell") as! BooleanInputCell
        
        cell.boolean.addTarget(self, action: #selector(self.switchStateChanged), for: .touchUpInside)
        
        cell.boolean.isOn = UserDefaults.standard.bool(forKey: "ReminderNotification")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Practicing regularly is important. When activated, we will send you a friendly reminder every now and then so you don’t forget your language goals."
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}
