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

class ConversationsVC: UIViewController, ConversationUpdateDelegate {
    
    func didUpdate(sender: Internet) {
        DispatchQueue.main.async {
            
            self.sortUsersByLastMessageDate()
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let updates = Internet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Internet.setUpListeners()
        
        setUpNavBar()
        
        self.view.backgroundColor = Colors.background_grey
        
        Internet.update_conversations_tableview_delegate = self
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
            performSegue(withIdentifier: "signOutUserSegue", sender: nil)
            return
        }
        
        self.title = "Conversations"
        self.tabBarController?.tabBar.items?[0].title = ""
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        Internet.getMaster()
        
        //filtered_converations = master?.conversations
        
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
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        guard let sender = sender as? CustomTapGesture else {
            return
        }
        
        let pin = UIAlertAction(title: "Pin/Unpin", style: .default) { (action) in
            sender.user.pinned_to_top = !sender.user.pinned_to_top
            self.sortUsersByLastMessageDate()
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        Alert.alert(title: "Options", message: "What would you like to do?", target: self, actions: [pin, cancel])
        
        print("I was long pressed")
    }
}

class CustomTapGesture: UILongPressGestureRecognizer {
    var user: User = User()
}

extension ConversationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if master.conversations.count == 0 {
            tableView.setEmptyView(title: "No conversations yet.", message: "Text a random person in the discover tab")
        }
        else {
            tableView.restore()
        }
        
        return master.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        
        let longPressRecognizer = CustomTapGesture(target: self, action: #selector(longPressed(sender:)))
        longPressRecognizer.user = master.conversations[indexPath.row]
        cell.addGestureRecognizer(longPressRecognizer)
        
        cell.name.attributedText = master.conversations[indexPath.row].fullname
        
        if master.conversations[indexPath.row].pinned_to_top {
            
            if #available(iOS 13.0, *) {
                
                let name = NSMutableAttributedString(string: master.conversations[indexPath.row].fullname.string + " ")
                
                let imageAttachment = NSTextAttachment()
                let config = UIImage.SymbolConfiguration(scale: .small)
                
                let image = UIImage(systemName: "pin.circle", withConfiguration: config)
                image?.withBaselineOffset(fromBottom: 1.0)
                imageAttachment.image = image
                name.append(NSAttributedString(attachment: imageAttachment))
                
                cell.name.attributedText = name
            }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        chatOf = master.conversations[indexPath.row]
        
        Navigation.push(viewController: "ChatVC", context: self)
        
    }
}

// To update the table view from another class
protocol ConversationUpdateDelegate {
    func didUpdate(sender: Internet)
}
