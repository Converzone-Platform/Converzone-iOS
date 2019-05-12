//
//  Conversations.swift
//  converzone
//
//  Created by Goga Barabadze on 28.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

//var filtered_converations: [User]? = nil

class ConversationsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        setUpNavBar()
        
        self.view.backgroundColor = Colors.backgroundGrey
        
        //navigationItem.searchController?.searchBar.delegate = self
        
        
    }
    
    func setUpFakeUsers(){
        
        let user = User(firstname: "Some", lastname: "Name", gender: .non_binary, birthdate: Date(timeIntervalSince1970: 0), uid: 19)
        
        master?.conversations.append(user)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //filtered_converations = master?.conversations

        master?.conversations.sort(by: { (user1, user2) -> Bool in
            return (user1.conversation.last?.date?.isGreaterThan((user2.conversation.last?.date)!))!

        })
        
        //MARK: TODO - Reloading the whole tableview might be too much
        tableView.reloadData()
    }
    
    func setUpNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        let searchBar = UISearchController(searchResultsController: nil)
//        navigationItem.searchController = searchBar
//        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension ConversationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return (filtered_converations?.count)!
        return (master?.conversations.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        
        cell.name.text = (master?.conversations[indexPath.row].firstname)! + " " + (master?.conversations[indexPath.row].lastname)!
        cell.profileImage.image = UIImage(named: String(arc4random_uniform(14)))
        cell.lastMessageType.backgroundColor = master?.conversations[indexPath.row].conversation.last?.color
        
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
