//
//  SettingsVC.swift
//  converzone
//
//  Created by Goga Barabadze on 18.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import NotificationCenter
import FirebaseAuth
import os
import Kingfisher

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var settings = ["", "Languages", "Country", "Reminder", "Blocked users", "Donate", "Sign out"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        master.editingMode = .editing
        
        Internet.getLanguagesFor(uid: master.uid, progress: "speak_languages") { (languages) in
            master.speak_languages = languages ?? []
            
            self.tableView.reloadData()
            
            if master.speak_languages.count == 0 {
                Navigation.push(viewController: "UsersLanguagesVC", context: self)
            }
        }
        
        Internet.getLanguagesFor(uid: master.uid, progress: "learn_languages") { (languages) in
            master.learn_languages = languages ?? []
            
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
            case 0: return 3
            case 1: return 2
            default: return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
            
        case 0:
            
            cell?.textLabel?.attributedText = master.fullname
            cell?.detailTextLabel?.text = master.status.string
            
            Internet.getImage(withURL: master.link_to_profile_image) { (image) in

                guard let image = image else {
                    os_log("Could not extract image.")
                    return
                }

                cell?.imageView?.image = self.resizeImageWithAspect(image: image, scaledToMaxWidth: 50, maxHeight: 50)
                cell?.imageView?.layer.cornerRadius = 25
                cell?.imageView?.layer.masksToBounds = true

                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            
            
            guard let image_view = cell?.imageView else {
                os_log("Could not get imageView.")
                return UITableViewCell()
            }

//            Internet.setImage(withURL: master.link_to_profile_image, imageView: image_view)
            
            cell?.accessoryType = .disclosureIndicator
            
        default:
            
            cell = UITableViewCell(style: .default, reuseIdentifier: "SettingsCell")
            
            cell?.textLabel?.text = settings[ tableView.globalIndexPath(for: indexPath as NSIndexPath) ]
            
            // Disable it for "Recommend"
            if settings[ tableView.globalIndexPath(for: indexPath as NSIndexPath) ] != "Recommend" {
                cell?.accessoryType = .disclosureIndicator
                
            }
            
            if settings[ tableView.globalIndexPath(for: indexPath as NSIndexPath) ] == "Reminder" {
                cell?.imageView?.image = UIImage(systemName: "calendar")
            }
            
            if settings[ tableView.globalIndexPath(for: indexPath as NSIndexPath) ] == "Blocked users" {
                cell?.imageView?.image = UIImage(systemName: "person.crop.circle.fill.badge.exclam")
            }
            
            if settings[ tableView.globalIndexPath(for: indexPath as NSIndexPath) ] == "Donate" {
                cell?.imageView?.image = UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
            }
            
        }
        
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
        case 0: Navigation.push(viewController: "EditProfileVC", context: self)
        case 1: Navigation.push(viewController: "UsersLanguagesVC", context: self)
        case 2: Navigation.push(viewController: "ContinentVC", context: self)
        case 3: performSegue(withIdentifier: "showReminderSettingsSegue", sender: self)
        case 4: performSegue(withIdentifier: "showBlockedUsersSegue", sender: self)
        case 5: performSegue(withIdentifier: "showDonationScreenSegue", sender: self)
        case 6:
            
            performSegue(withIdentifier: "signOutUserSegue", sender: nil)
            
            Internet.signOut()
        default: os_log("Clicked a button which is not there.")
        }
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0{
            return 100
        }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 3:
            return  "converzone ( v" + Bundle.main.releaseVersionNumber + " | build " + Bundle.main.buildVersionNumber + " )"
        default:
            return ""
        }
    }
    
    private func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
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
