//
//  AddConversation.swift
//  converzone
//
//  Created by Goga Barabadze on 15.04.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import ContactsUI
import MessageUI

class AddConversation: UIViewController {
    
    let contactStore = CNContactStore()
    var contacts = [CNContact]()
    
    override func viewWillAppear(_ animated: Bool) {
        getContacts()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func getContacts() {
        
        contacts = [CNContact]()
        
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [Any]
        
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                
                self.contacts.append(contact)
                
            }
        } catch {
            print("unable to fetch contacts")
        }
    
    }
}

extension AddConversation: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return /*2*/ 0
        case 1:
            return (master?.count_hidden_conversations)!
        case 2:
            return contacts.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateGroupCell") as! CreateGroupCell
            
            
            if indexPath.row == 0{
                cell.textLabel?.text = "Create new random Group"
            }else{
                cell.textLabel?.text = "Create new Group"
            }
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
            
            cell.textLabel?.text = master?.conversations[indexPath.row].fullname
//            cell.imageView?.image = UIImage(named: "1")
//
//            cell.imageView?.image = resizeImageWithAspect(image: UIImage(named: "1")!, scaledToMaxWidth: 40, maxHeight: 40)
//
//            cell.imageView?.layer.cornerRadius = 20
//            cell.imageView?.layer.masksToBounds = true
            
            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell") as! ContactsCell
            
            cell.textLabel?.text = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
            cell.detailTextLabel!.text = contacts[indexPath.row].phoneNumbers.first?.value.stringValue
            
            return cell
            
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell") as! ContactsCell
            
            cell.textLabel?.text = contacts[indexPath.row].givenName
            cell.detailTextLabel!.text = contacts[indexPath.row].phoneNumbers.first?.value.stringValue
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            
        case 0:
            return ""
            
        case 1:
            
            if (master?.count_hidden_conversations)! == 0{
                return ""
            }
            
            return "People you have already talked with"
            
        case 2:
            return "Invite people from your contacts"
            
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 1 /*&& (master?.count_hidden_conversations)! == 0*/{
            return 0
        }
        
        if section == 0{
            return 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
            
        case 0:
            
            print("notimplemented")
            
        case 1:
            print("notimplemented")
            
        case 2:
            
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                //controller.body = ""
                controller.recipients = [contacts[indexPath.row].phoneNumbers.first?.value.stringValue] as? [String]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
            
        default:
            print("notimplemented")
        }
        
    }
    
    func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
}

extension AddConversation: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
}
