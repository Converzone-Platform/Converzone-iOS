//
//  PhoneVerificationVC.swift
//  converzone
//
//  Created by Goga Barabadze on 25.10.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class PhoneVerificationVC: UIViewController {

    private var labels = ["Phone number",
                  "Send code"]
    
    private var footers = ["Carrier SMS charges may apply",
    "You must have received a 6 digit Code in a SMS. If not, try resending"]
    
    private var timer: Timer? = nil
    private var seconds_until_retry = 90
    
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
        return labels.count / 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.input?.placeholder = "e.g. +43 650 1234"
            cell.title?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            return cell
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendCodeCell")
            
            cell?.textLabel?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            cell?.textLabel?.textColor = Colors.blue
            
            return cell!
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalInputCell") as! NormalInputCell
            
            cell.input?.placeholder = "123456"
            
            if #available(iOS 12.0, *) {
                cell.input?.textContentType = .oneTimeCode
            }
            
            cell.title?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendCodeCell")
            
            cell?.textLabel?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            cell?.textLabel?.textColor = Colors.blue
            
            return cell!
            
        default:
            print("Bad indexPath")
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "SendCodeCell")!
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return footers[section]
    }
    
    
    /// Add the second section so that the user can enter the OTP
    /// - Parameter tableView: The tableView to which we add the section
    fileprivate func addNewSectionTo(_ tableView: UITableView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Add two new cells
            tableView.beginUpdates()
            
            self.labels.append("Code")
            self.labels.append("Check code")
            
            let indexSet = IndexSet(integer: 1)
            
            tableView.insertSections(indexSet, with: .fade)
            
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.globalIndexPath(for: indexPath as NSIndexPath) == 1 {
            
            // MARK: Check phone number
            
            guard let phone_number = (tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! NormalInputCell).input?.text else{
                return
            }
            
            Internet.verify(phoneNumber: phone_number)
        
            if (labels.count <= 2){
                addNewSectionTo(tableView)
            }
            
            // Start timer to prevent that we have to handle too many messages
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                
                let send_button_cell = tableView.cellForRow(at: IndexPath(row: 1 ,section: 0))
                
                send_button_cell?.textLabel?.text = "Didn't work? Try again in " + String(self.seconds_until_retry) + " seconds"
                send_button_cell?.isUserInteractionEnabled = false
                send_button_cell?.textLabel?.textColor = Colors.grey
                
                self.seconds_until_retry -= 1
                
                if self.seconds_until_retry == 0{
                    timer.invalidate()
                    self.seconds_until_retry = 90
                    
                    send_button_cell?.textLabel?.text = "Send code"
                    send_button_cell?.isUserInteractionEnabled = true
                    send_button_cell?.textLabel?.textColor = Colors.blue
                }
                
            })
            
        }
        
        if tableView.globalIndexPath(for: indexPath as NSIndexPath) == 3 {
            
            guard let code = (tableView.cellForRow(at: NSIndexPath(row: 0, section: 1) as IndexPath) as! NormalInputCell).input?.text else{
                return
            }
            
            Internet.signIn(with: code) { (success) in
                
                if success == false{
                    
                    alert("Wrong OTP", "Try resending the SMS", self)
                    
                    return
                }
                
                Navigation.push(viewController: "ContinentNC", context: self)
                
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath) {
        case 1:
            fallthrough
        case 3:
            let cell = tableView.cellForRow(at: indexPath)
            
            cell?.textLabel?.textColor = Colors.white
            cell?.contentView.backgroundColor = Colors.blue
            
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath) {
        case 1:
            fallthrough
        case 3:
            let cell = tableView.cellForRow(at: indexPath)
            
            cell?.textLabel?.textColor = Colors.blue
            cell?.contentView.backgroundColor = Colors.white
            
        default:
            return
        }
    }
    
}
