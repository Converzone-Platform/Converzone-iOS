//
//  PhoneVerificationVC.swift
//  converzone
//
//  Created by Goga Barabadze on 25.10.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class PhoneVerificationVC: UIViewController {

    var labels = ["Phone number",
                  "Send code"]
    
    var footers = ["Carrier SMS charges may apply"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
extension PhoneVerificationVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendCodeCell")
            
            cell?.textLabel?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            cell?.textLabel?.textColor = Colors.blue
            
            return cell!
            
        default:
            
            // NormalInputCell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.input?.placeholder = "e.g. +43 650 1234"
            cell.title?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return footers[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.globalIndexPath(for: indexPath as NSIndexPath) == 1 {
            
            // MARK: Check phone number
            
            guard let phone_number = (tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! NormalInputCell).input?.text else{
                return
            }
            
            Internet.verify(phoneNumber: phone_number)
        
            // Add two new cells
            
            labels.append("Code")
            labels.append("Check code")
            
            let indexSet = 1
            tableView.insertSections([indexSet], with: .automatic)
            
            let indexPath_1 = NSIndexPath(row: tableView.numberOfRows(inSection: 1), section: 0) as IndexPath
            let indexPath_2 = NSIndexPath(row: tableView.numberOfRows(inSection: 1), section: 1) as IndexPath
            
            tableView.insertRows(at: [indexPath_1, indexPath_2], with: UITableView.RowAnimation.automatic)
            
        }
        
    }
    
}
