//
//  DiscoverVC.swift
//  converzone
//
//  Created by Goga Barabadze on 17.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import os

var discover_users: [User] = []
var profile_of: User = User()
var fetched_count = 0

class DiscoverVC: UIViewController, DiscoverUpdateDelegate {
    
    private let number_of_items_for_fetch = 3
    private var discover_card: DicoverCard = DicoverCard()
    private let refresh = UIRefreshControl()
    
    let updates = Internet()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar()
        
        self.view.backgroundColor = Colors.background_grey
        
        Internet.update_discovery_tableview_delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if discover_users.count == 0 {
            
            fetchUsers()
            
        }
    }
    
    func didUpdate(sender: Internet) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc private func refreshUsers(sender: UIRefreshControl){
        
        sender.beginRefreshing()
        
        discover_users.removeAll()

        self.tableView.reloadData()
        
        //Internet.undiscoverable_counter = 0
        fetched_count = 0
        fetchUsers()
        
        sender.endRefreshing()
        
    }
    
    private func fetchUsers(){
        
        if no_discoverable_users_left {
            return
        }
        
        for _ in 0...number_of_items_for_fetch {
            Internet.findRandomUsers()
            
        }
    }
    
    private func setUpNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filter))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filter))
        }
        
        refresh.addTarget(self, action: #selector(refreshUsers( sender:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func filter(){
        performSegue(withIdentifier: "showDiscoverFilterSegue", sender: self)
    }
}

extension DiscoverVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //if (types[indexPath.row] == 3) { return }
        
        profile_of = discover_users[discover_users.index(discover_users.startIndex, offsetBy: indexPath.row)]
        
        self.discover_card.setUpCard(caller: self)
        self.discover_card.animateTransitionIfNeeded(state: self.discover_card.nextState, duration: 0.9)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if discover_users.count != 0 {
            tableView.restore()
            
            tableView.separatorStyle = .none
            
            return discover_users.count
        }
        
        tableView.setEmptyView(title: "No one to discover.", message: "Are you connected to the internet?")
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Don't display if we have reached the end
        if no_discoverable_users_left == true{
            
            tableView.tableFooterView = nil
            return
        }
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            tableView.tableFooterView = spinner
            tableView.tableFooterView?.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let discover_user = discover_users[safe: discover_users.index(discover_users.startIndex, offsetBy: indexPath.row)] else {
            
            os_log("Could not get user for discver tab.")
            
            return UITableViewCell()
        }
        
        return renderDiscoverCell(tableView, indexPath, discover_user)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        switch discover_users[discover_users.index(discover_users.startIndex, offsetBy: indexPath.row)].discover_style {
            case 0:
                
                guard let cell = tableView.cellForRow(at: indexPath) as? PicDiscoverCell else {
                    os_log("Could not retreave PicDiscoverCell")
                    return
                }
                
                UIView.animate(withDuration: 0.2) {
                    cell.view.alpha = 0.5
                }
            
            case 1:
                
                guard let cell = tableView.cellForRow(at: indexPath) as? StatusDiscoverCell else {
                    os_log("Could not retreave StatusDiscoverCell")
                    return
                }
                
                UIView.animate(withDuration: 0.2) {
                    cell.view.alpha = 0.5
                }
            
            
            default: return
        }
        
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        switch discover_users[discover_users.index(discover_users.startIndex, offsetBy: indexPath.row)].discover_style {
            case 0:
                
                guard let cell = tableView.cellForRow(at: indexPath) as? PicDiscoverCell else {
                    os_log("Could not retreave PicDiscoverCell")
                    return
                }
                
                UIView.animate(withDuration: 0.5) {
                    cell.view.alpha = 1
                }
            
            case 1:
                
                guard let cell = tableView.cellForRow(at: indexPath) as? StatusDiscoverCell else {
                    os_log("Could not retreave StatusDiscoverCell")
                    return
                }
                
                UIView.animate(withDuration: 0.5) {
                    cell.view.alpha = 1
                }
            
            
            default: return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch discover_users[discover_users.index(discover_users.startIndex, offsetBy: indexPath.row)].discover_style{
        case 0:
            return 250
        case 1:
            return 250
        case 2:
            return 400
        case 3:
            return 100
        default:
            return 250
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
protocol DiscoverUpdateDelegate {
    func didUpdate(sender: Internet)
}
