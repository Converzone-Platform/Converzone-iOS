//
//  Conversations.swift
//  converzone
//
//  Created by Goga Barabadze on 28.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

//var filtered_converations: [User]? = nil

class ConversationsVC: UIViewController, ConversationUpdateDelegate {
    
    func didUpdate(sender: Internet) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let updates = Internet()
    
    override func viewDidLoad() {
        
        setUpNavBar()
        
        self.view.backgroundColor = Colors.backgroundGrey
        
        //navigationItem.searchController?.searchBar.delegate = self
        
        updates.conversations_delegate = self
        
        if master?.addedUserSinceLastConnect == false{
            master?.addedUserSinceLastConnect = true
            socket.emit("add-user", with: [["id": master?.uid]])
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Conversations"
        self.tabBarController?.cleanTitles()
        //filtered_converations = master?.conversations
                master?.conversations.sort(by: { (user1, user2) -> Bool in
                    return (user1.conversation.last?.date?.isGreaterThan((user2.conversation.last?.date)!))!
        
                })
        
        //MARK: TODO - Reloading the whole tableview might be too much
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.title = ""
    }
    
    func setUpNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        let searchBar = UISearchController(searchResultsController: nil)
//        navigationItem.searchController = searchBar
//        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                    
                    // MARK: TODO - Tell database that this client deleted the chat
                    master?.conversations[indexPath.row].conversation.removeAll()
                    master?.conversations.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
                let clear = UIAlertAction(title: "Clear", style: .destructive) { (action) in
                    master?.conversations[indexPath.row].conversation.removeAll()
                    
                    // Add First Message
                    let firstMessage = FirstInformationMessage()
                    
                    firstMessage.text = "Here we go again :D"
                    
                    master?.conversations[indexPath.row].conversation.append(firstMessage)
                }
                
                let silence = UIAlertAction(title: "Silence", style: .default) { (action) in
                    
                }
                
                alertController.addAction(delete)
                alertController.addAction(clear)
                //alertController.addAction(silence)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension ConversationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return (filtered_converations?.count)!
        
        if master?.conversations.count == 0 {
            tableView.setEmptyView(title: "No conversations yet.", message: "Text a random person in the discover tab")
        }
        else {
            tableView.restore()
        }
        
        return (master?.conversations.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        cell.addGestureRecognizer(longPressRecognizer)
        
        cell.name.text = master?.conversations[indexPath.row].fullname
        
        master?.conversations[indexPath.row].getImage(with: (master?.conversations[indexPath.row].link_to_profile_image)!, completion: { (image) in
            
            cell.profileImage.image = image
            
        })
        
        if (master?.conversations[indexPath.row].openedChat)! {
            cell.lastMessageType.backgroundColor = Colors.white
        }else{
            cell.lastMessageType.backgroundColor = master?.conversations[indexPath.row].conversation.last?.color
        }
        
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



//extension ConversationsVC: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        
//        guard !searchText.isEmpty else {
//            filtered_converations = master?.conversations
//            tableView.reloadData()
//            return
//        }
//        
//        filtered_converations = master?.conversations.filter({ (user) -> Bool in
//            return (user.fullname?.lowercased().contains(searchText.lowercased()))!
//        })
//        
//        tableView.reloadData()
//    }
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.endEditing(true)
//        
//        filtered_converations = master?.conversations
//        tableView.reloadData()
//    }
//}

// To update the table view from another class
protocol ConversationUpdateDelegate {
    func didUpdate(sender: Internet)
}
