//
//  Conversations.swift
//  converzone
//
//  Created by Goga Barabadze on 28.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import FirebaseAuth
import os
import SwiftDesign

class ConversationsVC: UIViewController, ConversationUpdateDelegate, DiscoverUpdateDelegate {
    
    func didUpdate(sender: Internet) {
        DispatchQueue.main.async {
            
            self.sortUsersByLastMessageDate()
            self.tableView.reloadData()
        }
    }
    
    private let number_of_items_for_fetch = 3
    private var discover_card: DicoverCard = DicoverCard()
    
    @IBOutlet weak var tableView: UITableView!
    
    let updates = Internet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Internet.setUpListeners()
        
        setUpNavBar()
        
        self.view.backgroundColor = Colors.background_grey
        
        Internet.update_conversations_tableview_delegate = self
        Internet.update_discovery_tableview_delegate = self
        
        if discover_users.count == 0 {
            fetchUsers()
        }
    }
    
    private func sortUsersByLastMessageDate() {
        
        master.conversations.sort(by: { (user1, user2) -> Bool in
            
            if user1.pinned_to_top == true && !user2.pinned_to_top {
                return true
            }
            
            if user2.pinned_to_top == true && !user1.pinned_to_top {
                return false
            }
            
            guard let date_1 = user1.conversation.last?.date,
                let date_2 = user2.conversation.last?.date else {
                    
                    os_log("Could not extract date from user.")
                    
                    return false
            }
            
            return date_1.timeIntervalSince1970 >= date_2.timeIntervalSince1970
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Navigation.didNotFinishRegistration() {
            performSegue(withIdentifier: "signOutUserSegue", sender: self)
            return
        }
        
        self.title = "Converzone"
        self.tabBarController?.tabBar.items?[0].title = ""
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        Internet.getMaster()
        
        sortUsersByLastMessageDate()
        
        //MARK: TODO - Reloading the whole tableview might be too much
        tableView.reloadData()
        
        getNotificationPermissionFromUser()
    }
    
    /// Ask if we can send notifications to this device
    private func getNotificationPermissionFromUser() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (bool, error) in
            
            Internet.upload(token: Internet.fcm_token)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.title = ""
    }
    
    private func setUpNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func fetchUsers(){
        
        if no_discoverable_users_left {
            return
        }
        
        for _ in 0...number_of_items_for_fetch {
            Internet.findRandomUsers()
            
        }
    }
}

extension ConversationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ["Conversations", "Discover"][section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if master.conversations.count == 0 {
                tableView.setEmptyView(title: "No conversations yet.", message: "Text a random person in the discover tab")
            }
            else {
                tableView.restore()
            }
            
            return master.conversations.count
        }else{
            return discover_users.count
        }
    }
    
    fileprivate func renderConversationCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        
        cell.name.attributedText = master.conversations[indexPath.row].fullname
        
        if master.conversations[indexPath.row].pinned_to_top {
            
            let name = NSMutableAttributedString(string: master.conversations[indexPath.row].fullname.string + " ")
            
            let imageAttachment = NSTextAttachment()
            let config = UIImage.SymbolConfiguration(scale: .small)
            
            let image = UIImage(systemName: "pin.circle", withConfiguration: config)
            image?.withBaselineOffset(fromBottom: 1.0)
            imageAttachment.image = image
            name.append(NSAttributedString(attachment: imageAttachment))
            
            cell.name.attributedText = name
        }
        
        Internet.setImage(withURL: master.conversations[indexPath.row].link_to_profile_image, imageView: cell.profile_image)
        
        if master.conversations[indexPath.row].openedChat || master.conversations[indexPath.row].conversation.last?.is_sender ?? false {
            cell.last_message_type.backgroundColor = Colors.white
        }else{
            cell.last_message_type.backgroundColor = master.conversations[indexPath.row].conversation.last?.color
        }
        
        cell.profile_image.roundCorners(radius: cell.profile_image.layer.frame.width / 2, masksToBounds: true)
        
        cell.last_message_type.roundCorners(radius: cell.last_message_type.layer.frame.width / 2)
        
        cell.view.roundCorners(radius: 2)
        
        cell.view.addShadow(radius: 3.0, opacity: 0.2, offset: CGSize(width: 0, height: 0), color: .black)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            return renderConversationCell(tableView, indexPath)
        }else{
            
            guard let discover_user = discover_users[safe: discover_users.index(discover_users.startIndex, offsetBy: indexPath.row)] else {
                
                os_log("Could not get user for discver tab.")
                
                return UITableViewCell()
            }
            
            return renderPicDiscoverCell(tableView, indexPath, discover_user)
        }
        
    }
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        [110, 250][indexPath.section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            chatOf = master.conversations[indexPath.row]
            
            Navigation.push(viewController: "ChatVC", context: self)
        }else{
            profile_of = discover_users[discover_users.index(discover_users.startIndex, offsetBy: indexPath.row)]
            
            self.discover_card.setUpCard(caller: self)
            self.discover_card.animateTransitionIfNeeded(state: self.discover_card.nextState, duration: 0.9)
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 2000 {
            fetchUsers()
        }
    }
}

// To update the table view from another class
protocol ConversationUpdateDelegate {
    func didUpdate(sender: Internet)
}
