//
//  Conversations.swift
//  converzone
//
//  Created by Goga Barabadze on 28.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class ConversationsVC: UIViewController {
    
    override func viewDidLoad() {
        
        setUpNavBar()
        setUpFakeUsers()
        
        self.view.backgroundColor = Colors.backgroundGrey
    }
    
    func setUpFakeUsers(){
        
        let user_1 = User(firstname: "John", lastname: "Jefferson", gender: .male, birthdate: Date(timeIntervalSince1970: 0))
        
        user_1.chat.append(TextMessage(text: "Hey! I am John!", is_sender: false))
        user_1.chat.append(TextMessage(text: "How are you doing, John?", is_sender: true))
        
        
        let user_2 = User(firstname: "Jack", lastname: "Miller", gender: .male, birthdate: Date(timeIntervalSince1970: 0))
        
        user_2.chat.append(TextMessage(text: "Hello Goga!", is_sender: false))
        user_2.chat.append(TextMessage(text: "How are you?", is_sender: false))
        user_2.chat.append(ImageMessage(image: UIImage(named: "1")!, is_sender: true))
        
        master?.chats.append(user_1)
        master?.chats.append(user_2)
        
    }
    
    func setUpNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchBar = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension ConversationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (master?.chats.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        
        cell.name.text = (master?.chats[indexPath.row].firstname)! + " " + (master?.chats[indexPath.row].lastname)!
        cell.profileImage.image = UIImage(named: String(arc4random_uniform(14)))
        cell.lastMessageType.backgroundColor = master?.chats[indexPath.row].chat.last?.color
        
        cell.profileImage.layer.cornerRadius = cell.profileImage.layer.frame.width / 2
        cell.profileImage.layer.masksToBounds = true
        
        cell.lastMessageType.layer.cornerRadius = cell.lastMessageType.layer.frame.width / 2
        
        cell.view.layer.cornerRadius = 2
        cell.view.layer.shadowColor = UIColor.black.cgColor
        cell.view.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.view.layer.shadowOpacity = 0.2
        cell.view.layer.shadowRadius = 3.0
        
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
        
        chatOf = master?.chats[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let balanceViewController = storyBoard.instantiateViewController(withIdentifier: "ChatVC")
        self.navigationController?.pushViewController(balanceViewController, animated: true)
        
    }
}
