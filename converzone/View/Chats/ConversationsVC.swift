//
//  Conversations.swift
//  converzone
//
//  Created by Goga Barabadze on 28.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class ConversationsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var filtered_converations: [User]? = nil
    
    override func viewDidLoad() {
        
        setUpNavBar()
        setUpFakeUsers()
        
        self.view.backgroundColor = Colors.backgroundGrey
        
        navigationItem.searchController?.searchBar.delegate = self
        
        
    }
    
    func setUpFakeUsers(){
        
        let user_1 = User(firstname: "John", lastname: "Jefferson", gender: .male, birthdate: Date())
        
        user_1.chat.append(TextMessage(text: "Hey! I am John!", is_sender: false))
        user_1.chat.append(TextMessage(text: "How are you doing, John?", is_sender: true))
        
        
        let user_2 = User(firstname: "Jack", lastname: "Miller", gender: .male, birthdate: Date())
        
        user_2.chat.append(TextMessage(text: "Hello!", is_sender: false))
        user_2.chat.append(TextMessage(text: "How are you?", is_sender: false))
        user_2.chat.append(ImageMessage(image: UIImage(named: "1")!, is_sender: true))
        
        let user_3 = User(firstname: "Lebrone", lastname: "Hasher", gender: .male, birthdate: Date())
        
        user_3.chat.append(TextMessage(text: "Bonjour mon ami!", is_sender: false))
        user_3.chat.append(TextMessage(text: "Comment ça va?", is_sender: false))
        user_3.chat.append(ImageMessage(image: UIImage(named: "4")!, is_sender: true))
        user_3.chat.append(ImageMessage(image: UIImage(named: "6")!, is_sender: false))
        user_3.chat.append(ImageMessage(image: UIImage(named: "0")!, is_sender: true))
        user_3.chat.append(ImageMessage(image: UIImage(named: "2")!, is_sender: false))
        user_3.chat.append(ImageMessage(image: UIImage(named: "8")!, is_sender: true))
        user_3.chat.append(ImageMessage(image: UIImage(named: "1")!, is_sender: true))
        
        master?.chats.append(user_1)
        master?.chats.append(user_2)
        master?.chats.append(user_3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpFakeUsers()
        filtered_converations = master?.chats
        
        master?.chats.sort(by: { (user1, user2) -> Bool in
            return (user1.chat.last?.date?.isGreaterThan((user2.chat.last?.date)!))!  
            
        })
        
        //MARK: TODO - Reloading the whole tableview might be too much
        tableView.reloadData()
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
        return (filtered_converations?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        
        cell.name.text = (filtered_converations![indexPath.row].firstname)! + " " + (filtered_converations![indexPath.row].lastname)!
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
        
        indexOfUser = indexPath.row
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let balanceViewController = storyBoard.instantiateViewController(withIdentifier: "ChatVC")
        self.navigationController?.pushViewController(balanceViewController, animated: true)
        
    }
}

extension Date {
    
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }
    
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }
}

extension ConversationsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            filtered_converations = master?.chats
            tableView.reloadData()
            return
        }
        
        filtered_converations = master?.chats.filter({ (user) -> Bool in
            return (user.fullname?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        filtered_converations = master?.chats
        tableView.reloadData()
    }
}
