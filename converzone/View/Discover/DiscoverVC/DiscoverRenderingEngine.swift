//
//  DiscoverRenderingEngine.swift
//  converzone
//
//  Created by Goga Barabadze on 25.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import UIKit
import os

extension DiscoverVC {
    
    fileprivate func renderPicDiscoverCell(_ tableView: UITableView, _ indexPath: IndexPath, _ user: User) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PicDiscoverCell") as! PicDiscoverCell
        
        cell.name.attributedText = user.fullname
        
        Internet.setImage(withURL: user.link_to_profile_image, imageView: cell.profile_image)
        
        cell.profile_image.contentMode = .scaleAspectFill
        cell.profile_image.clipsToBounds = true
        
        cell.profile_image.roundCorners(radius: 23, masksToBounds: true)
        
        cell.profile_image.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        cell.view.roundCorners(radius: 23)
        cell.view.addShadow()
        
        return cell
    }
    
    fileprivate func renderStatusDiscoverCell(_ tableView: UITableView, _ indexPath: IndexPath, _ user: User) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusDiscoverCell") as! StatusDiscoverCell
        
        cell.name.attributedText = user.fullname
        
        Internet.setImage(withURL: user.link_to_profile_image, imageView: cell.profile_image)
        
        cell.profile_image.roundCorners(radius: cell.profile_image.layer.frame.width / 2, masksToBounds: true)
        
        cell.profile_image.contentMode = .redraw
        
        cell.view.roundCorners(radius: 23)
        cell.view.addShadow()
        
        cell.status.text = user.status.string
        
        return cell
    }
    
    func renderDiscoverCell(_ tableView: UITableView, _ indexPath: IndexPath, _ user: User) -> UITableViewCell {
        
        switch user.discover_style {
            
        case 0: return renderPicDiscoverCell(tableView, indexPath, user)
            
        case 1: return renderStatusDiscoverCell(tableView, indexPath, user)
            
        default:
            os_log("Wants to render cell type which isn't implemented yet.")
            return UITableViewCell()
        }
    }
    
}
