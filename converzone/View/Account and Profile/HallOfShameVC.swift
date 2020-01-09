//
//  HallOfShameVC.swift
//  converzone
//
//  Created by Goga Barabadze on 22.12.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class HallOfShameVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var sorted_blocked_users = master.blocked_users.sorted()
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.setEditing(true, animated: animated)
        
        sorted_blocked_users = master.blocked_users.sorted()
        
    }
    
    private func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height : CGFloat)->UIImage? {
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

extension HallOfShameVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sorted_blocked_users.count == 0{
            tableView.setEmptyView(title: "No blocked users", message: "The users you block will appear here")
        }
        
        return sorted_blocked_users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        Internet.getUser(with: sorted_blocked_users[indexPath.row]) { (user) in
            
            Internet.getImage(withURL: user!.link_to_profile_image) { (image) in
                
                let resized = self.resizeImageWithAspect(image: image!, scaledToMaxWidth: 24.0, maxHeight: 24.0)
                
                cell.imageView?.layer.cornerRadius = 12
                cell.imageView?.layer.masksToBounds = true
                
                cell.imageView!.image = resized
            }
            
            cell.textLabel!.text = user?.fullname.string
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if(editingStyle == .delete){
            
            Internet.getUser(with: sorted_blocked_users[indexPath.row]) { (user) in
                Internet.unblock(userid: user!.uid)
            }
            
            sorted_blocked_users.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unblock"
    }
    
}
