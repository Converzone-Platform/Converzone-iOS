//
//  PhoneVerificationVC.swift
//  converzone
//
//  Created by Goga Barabadze on 25.10.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import os
import PhoneNumberKit
import NVActivityIndicatorView

class PhoneVerificationVC: NoAutoRotateViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var labels = ["Phone number", "Send code"]
    private var footer_notes = ["Carrier SMS charges may apply.", "You must have received a 6 digit Code within a SMS. If not, try resending."]
    private var timer: Timer? = nil
    
    private var seconds_until_retry = 25
    private var tries = 0
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
            
            cell.textLabel?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            cell.input?.textContentType = .telephoneNumber
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendCodeCell")
            
            cell?.textLabel?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            cell?.textLabel?.textColor = Colors.blue
            cell?.selectionStyle = .none
             
            return cell!
            
        case 2:
             
            let cell = tableView.dequeueReusableCell(withIdentifier: "NormalOTPCell") as! NormalInputCell
             
            cell.textLabel?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            cell.input?.becomeFirstResponder()
            
            if #available(iOS 12.0, *) {
                cell.input?.textContentType = .oneTimeCode
            }
            
            cell.title?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SendCodeCell")
            
            cell?.textLabel?.text = labels[tableView.globalIndexPath(for: indexPath as NSIndexPath)]
            cell?.textLabel?.textColor = Colors.blue
            cell?.selectionStyle = .none
              
            return cell!
            
        default:
            #warning("Error message needed")
        }
        return tableView.dequeueReusableCell(withIdentifier: "SendCodeCell")!
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return footer_notes[section]
    }
    
    /// Add the second section so that the user can enter the OTP
    /// - Parameter tableView: The tableView to which we add the section
    fileprivate func addNewSectionTo(_ tableView: UITableView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Add two new cells
            tableView.beginUpdates()
            
            self.labels.append("Code (OTP)")
            self.labels.append("Check code")
            
            let indexSet = IndexSet(integer: 1)
            
            tableView.insertSections(indexSet, with: .fade)
            
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.globalIndexPath(for: indexPath as NSIndexPath) == 1 {
            
            // Check for internet connection
            if !Internet.isOnline() {
                
                alert("You seem to be offline", "Please establish an internet connection.")
                
                return
            }
            
            let send_button_cell = tableView.cellForRow(at: IndexPath(row: 1 ,section: 0))
            
            // MARK: Check phone number
            guard let phonenumber = (tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! NormalInputCell).input?.text else {
                return
            }
            
            if phonenumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return
            }
            
            tries += 1
            
            master.phonenumber = phonenumber
            
            Internet.verify(phoneNumber: phonenumber)
        
            if (labels.count <= 2){
                addNewSectionTo(tableView)
            }
            
            if tries <= 5 {
                return
            }
            
            send_button_cell?.isUserInteractionEnabled = false
            
            seconds_until_retry = 10 * tries
            
            // Start timer to prevent that we have to handle too many messages
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                
                let send_button_cell = tableView.cellForRow(at: IndexPath(row: 1 ,section: 0))
                
                send_button_cell?.textLabel?.text = "Didn't work? Try again in " + String(self.seconds_until_retry) + " seconds"
                send_button_cell?.isUserInteractionEnabled = false
                send_button_cell?.textLabel?.textColor = Colors.grey
                
                self.seconds_until_retry -= 1
                
                if self.seconds_until_retry == -1 {
                    timer.invalidate()
                    self.seconds_until_retry = 10 * self.tries
                    
                    send_button_cell?.textLabel?.text = "Send code"
                    send_button_cell?.isUserInteractionEnabled = true
                    send_button_cell?.textLabel?.textColor = Colors.blue
                }
                
            })
            
        }
        
        if tableView.globalIndexPath(for: indexPath as NSIndexPath) == 3 {
            
            guard let code = (tableView.cellForRow(at: NSIndexPath(row: 0, section: 1) as IndexPath) as! NormalInputCell).input?.text else {
                return
            }
            
            if code.isEmpty {
                alert("No Code", "Please enter the code you received from the SMS. If you didn't receive one, try resending again.")
                return
            }
            
            // Start animating
            let loading_animation = NVActivityIndicatorView(frame: self.view.bounds, type: .ballScaleMultiple, color: .white, padding: nil)
            self.view.addSubview(loading_animation)
            loading_animation.startAnimating()
            
            // Stop animation in 7 seconds
            Timer.scheduledTimer(withTimeInterval: 7, repeats: false) { (timer) in
                loading_animation.removeFromSuperview()
            }
            
            Internet.signIn(with: code) { (error) in
                
                loading_animation.removeFromSuperview()
                
                if error != nil{
                    
                    alert("Something went wrong", "Try resending the SMS")
                    
                    return
                }
                
                alert("Verified", "Let's continue with entering further user information now") {
                    
                   // Does this user already exist?
                    
                    Internet.doesUserExist(uid: master.uid) { (exists) in
                        if exists {
                            master.editingMode = .editing
                            
                            UserDefaults.standard.set(true, forKey: "DidFinishRegistration")
                            
                            Internet.getMaster()
                            
                            Internet.setUpListeners()
                            
                            Internet.upload(token: master.device_token)
                            
                            self.performSegue(withIdentifier: "showActualAppSegue", sender: nil)
                        }else{
                            self.performSegue(withIdentifier: "userWasVerifiedSegue", sender: self)
                        }
                    }
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        if tableView.globalIndexPath(for: indexPath as NSIndexPath) == 0 || tableView.globalIndexPath(for: indexPath as NSIndexPath) == 2{
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        
        UIView.animate(withDuration: 0.2) {
            cell?.contentView.alpha = 0.5
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        if tableView.globalIndexPath(for: indexPath as NSIndexPath) == 0 || tableView.globalIndexPath(for: indexPath as NSIndexPath) == 2{
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        
        UIView.animate(withDuration: 0.5) {
            cell?.contentView.alpha = 1
        }
    }
    
}
