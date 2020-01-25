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
        
        // Don't do it if there are users without a message
        master.conversations.forEach { (user) in
            if user.conversation.count == 0{
                return
            }
        }
        
        master.conversations.sort(by: { (user1, user2) -> Bool in
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
        
    }
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
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        cell.addGestureRecognizer(longPressRecognizer)
        
        cell.name.attributedText = master.conversations[indexPath.row].fullname
        
        Internet.getImage(withURL: master.conversations[indexPath.row].link_to_profile_image) { (image) in
            cell.profile_image.image = image
        }
        
        if master.conversations[indexPath.row].openedChat || master.conversations[indexPath.row].conversation.last?.is_sender ?? false{
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
