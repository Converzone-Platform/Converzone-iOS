//
//  SettingsVC.swift
//  converzone
//
//  Created by Goga Barabadze on 18.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import NotificationCenter

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var settings = ["", "Languages", "Country", "Recommend", "Sign out"]
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        self.title = "Settings"
        self.tabBarController?.cleanTitles()
        
        master?.changingData = .editing
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3
        }
        
        return 1
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
            
        case 0:
            
            cell?.textLabel?.text = master?.fullname
            cell?.detailTextLabel?.text = master?.status?.string
            
            if master!.changed_image{
                master?.changed_image = false
                
                cell?.imageView?.image = nil
            }
            
            if cell?.imageView!.image == nil{
                master?.getImage(with: "http://converzone.htl-perg.ac.at/profile_images/" + (master?.lastname)! + "_" + String(master!.uid!) + "_profile_image", completion: { (image) in
                    
                    if image == nil{
                        return
                    }
                    
                    cell?.imageView!.image = self.resizeImageWithAspect(image: image!, scaledToMaxWidth: 50, maxHeight: 50)

                    tableView.reloadData()
                })
            }
            
            cell?.imageView!.layer.cornerRadius = 25
            cell?.imageView!.layer.masksToBounds = true
            
            //cell?.imageView?.contentMode = .scaleAspectFill
            
            cell?.accessoryType = .disclosureIndicator
            
        default:
            
            cell = UITableViewCell(style: .default, reuseIdentifier: "SettingsCell")
            
            //cell?.imageView?.image = UIImage(named: "austria")
            
            cell?.textLabel?.text = settings[ tableView.globalIndexPath(for: indexPath as NSIndexPath) ]
            
            // Disable it for "Recommend"
            if settings[ tableView.globalIndexPath(for: indexPath as NSIndexPath) ] != "Recommend"{
                cell?.accessoryType = .disclosureIndicator
                
            }
        }
        
        cell!.selectionStyle = .none
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView.globalIndexPath(for: indexPath as NSIndexPath){
        case 0:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC")
            self.navigationController?.pushViewController(vc!, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        case 1:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UsersLanguagesVC")
            self.navigationController?.pushViewController(vc!, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        case 2:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContinentVC")
            self.navigationController?.pushViewController(vc!, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        case 3:
            
            // MARK: TODO - This is probably not working! Change to correct link
            "Check this out: http://itunes.apple.com/app/id1465102094".share()
            
        case 4:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            present(vc!, animated: true, completion: nil)
            self.tabBarController?.tabBar.isHidden = true
            
            // Delete discover users
            discover_users.removeAll()
            
            master?.addedUserSinceLastConnect = false
            
            master?.cache.removeAllObjects()
            
        default:
            print("No action here")
        }
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
