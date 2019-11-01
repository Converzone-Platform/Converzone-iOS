//
//  DiscoverVC.swift
//  converzone
//
//  Created by Goga Barabadze on 17.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit


var discover_users: [User] = []
var profileOf: User = User()

var reachedTheEndForDiscoverableUsers: Bool {
    return Internet.user_count-1 == discover_users.count
}

class DiscoverVC: UIViewController, DiscoverUpdateDelegate {
    
    private let numberOfItemsPerFetch = 11
    private var fetchedCount = 0
    private var discoverCard: DicoverCard = DicoverCard()
    private let refreshControl = UIRefreshControl()
    
    // To update the table view from the Internet class
    let updates = Internet()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar()
        
        self.view.backgroundColor = Colors.backgroundGrey
        
        Internet.update_discovery_tableview_delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if discover_users.isEmpty && Internet.isOnline(){
            
            fetchUsers()
            fetchedCount = 0
            
        }
    }
    
    func didUpdate(sender: Internet) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc private func refreshUsers(sender: UIRefreshControl){
        
        sender.beginRefreshing()
        
        // Delete the old ones
        discover_users.removeAll()

        // Update the table view
        self.tableView.reloadData()
        
        fetchUsers()
        fetchedCount = 0
        
        sender.endRefreshing()
        
    }
    
    private func fetchUsers(){
        
        if reachedTheEndForDiscoverableUsers {
            return
        }
        
        fetchedCount += numberOfItemsPerFetch
//
//        let user = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eiewdwwdasuqzeiu")
//        let user1 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eiewasdasdasdwwuqzeiu")
//        let user2 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eiewdwasdwuqzeiu")
//        let user3 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eiedad243swdwadawuqzeiu")
//        let user4 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eiew3424234da34sdwwuqzeiu")
//        let user5 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eiewd234wwuqzeiu")
//        let user6 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131ei424esa4234dwdwwuqzeiu")
//        let user7 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eiesadwadsasdsdwwuqzeiu")
//        let user8 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eieasaswdwwuqzeiu")
//        let user9 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131e423iewdwwuq3242423423432434zeiu")
//        let user10 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "34")
//        let user11 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "123")
//        let user12 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eiad42sdsdasdsadewdwwuqzeiu")
//        let user13 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "213123441eie42334wdwwuqzeiu")
//        let user14 = User(firstname: "Lucie", lastname: "Deroo", gender: .female, birthdate: Date(), uid: "2131eie342wdwwuqzeiu")
//
//        user.link_to_profile_image = "https://picsum.photos/id/1/500/500"
//        user1.link_to_profile_image = "https://picsum.photos/id/11/500/500"
//        user2.link_to_profile_image = "https://picsum.photos/id/12/500/500"
//        user3.link_to_profile_image = "https://picsum.photos/id/13/500/500"
//        user4.link_to_profile_image = "https://picsum.photos/id/14/500/500"
//        user5.link_to_profile_image = "https://picsum.photos/id/15/500/500"
//        user6.link_to_profile_image = "https://picsum.photos/id/16/500/500"
//        user7.link_to_profile_image = "https://picsum.photos/id/17/500/500"
//        user8.link_to_profile_image = "https://picsum.photos/id/18/500/500"
//        user9.link_to_profile_image = "https://picsum.photos/id/19/500/500"
//        user10.link_to_profile_image = "https://picsum.photos/id/20/500/500"
//        user11.link_to_profile_image = "https://picsum.photos/id/21/500/500"
//        user12.link_to_profile_image = "https://picsum.photos/id/22/500/500"
//        user13.link_to_profile_image = "https://picsum.photos/id/23/500/500"
//        user14.link_to_profile_image = "https://picsum.photos/id/24/500/500"
//
//        discover_users.append(user)
//        discover_users.append(user1)
//        discover_users.append(user2)
//        discover_users.append(user3)
//        discover_users.append(user4)
//        discover_users.append(user5)
//        discover_users.append(user6)
//        discover_users.append(user7)
//        discover_users.append(user8)
//        discover_users.append(user9)
//        discover_users.append(user10)
//        discover_users.append(user11)
//        discover_users.append(user12)
//        discover_users.append(user13)
//        discover_users.append(user14)
        
        for _ in 0...numberOfItemsPerFetch {
            Internet.getRandomUser()
        }
        
    }
    
    
    private func setUpNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // This is not finished yet
//        let searchBar = UISearchController(searchResultsController: nil)
//        navigationItem.searchController = searchBar
//        navigationItem.hidesSearchBarWhenScrolling = false
        
        //let filter_button = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Button text for Filter Discover"), style: .plain, target: self, action: nil)
        
        refreshControl.addTarget(self, action: #selector(refreshUsers( sender:)), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
}

extension DiscoverVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //if (types[indexPath.row] == 3) { return }
        
        profileOf = discover_users[indexPath.row]
        
        self.discoverCard.setUpCard(caller: self)
        self.discoverCard.animateTransitionIfNeeded(state: self.discoverCard.nextState, duration: 0.9)
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
        if reachedTheEndForDiscoverableUsers == true{
            
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
        
        switch discover_users[indexPath.row].discover_style {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PicDiscoverCell") as! PicDiscoverCell
            
            cell.name.text = discover_users[indexPath.row].fullname
            
            Internet.getImage(withURL: discover_users[indexPath.row].link_to_profile_image) { (image) in
                cell.profileImage.image = image
            }
            
            cell.profileImage.contentMode = .scaleAspectFill
            cell.profileImage.clipsToBounds = true
            cell.profileImage.layer.cornerRadius = 23
            cell.profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusDiscoverCell") as! StatusDiscoverCell
            
            cell.name.text = discover_users[indexPath.row].fullname
            
            Internet.getImage(withURL: discover_users[indexPath.row].link_to_profile_image) { (image) in
                cell.profileImage.image = image
            }
            
            cell.profileImage.layer.cornerRadius = cell.profileImage.layer.frame.width / 2
            cell.profileImage.layer.masksToBounds = true
            cell.profileImage.contentMode = .redraw
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.status.text = discover_users[indexPath.row].status.string
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReflectionDiscoverCell") as! ReflectionDiscoverCell
            
            cell.name.text = discover_users[indexPath.row].fullname
            
            Internet.getImage(withURL: discover_users[indexPath.row].link_to_profile_image) { (image) in
                cell.profileImage.image = image
            }
            
            cell.profileImage.layer.cornerRadius = 23
            cell.profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.profileImage.layer.masksToBounds = true
            cell.profileImage.contentMode = .redraw
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.reflection.text = "That’s why they call it the American Dream, because you have to be asleep to believe it. George Carlin -- If you’re too open-minded; your brains will fall out. Lawrence Ferlinghetti"
            cell.reflectionWriter.text = "~ George Long"
            
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RandomDiscoverCell") as! RandomDiscoverCell
            
            cell.group_outlet.layer.shadowColor = UIColor.black.cgColor
            cell.group_outlet.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.group_outlet.layer.shadowOpacity = 0.3
            cell.group_outlet.layer.shadowRadius = 4.0
            
            cell.person_outlet.layer.shadowColor = UIColor.black.cgColor
            cell.person_outlet.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.person_outlet.layer.shadowOpacity = 0.3
            cell.person_outlet.layer.shadowRadius = 4.0
            
            return cell
            
        default:
            print("Something bad happened while choosing the cell type")
            return tableView.dequeueReusableCell(withIdentifier: "ReflectionDiscoverCell") as! ReflectionDiscoverCell
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        switch discover_users[indexPath.row].discover_style {
            case 0:
                let cell = tableView.cellForRow(at: indexPath) as! PicDiscoverCell
                
                UIView.animate(withDuration: 0.2) {
                    cell.view.alpha = 0.5
                }
            
            case 1:
                let cell = tableView.cellForRow(at: indexPath) as! StatusDiscoverCell
            
                UIView.animate(withDuration: 0.2) {
                    cell.view.alpha = 0.5
                }
            
            case 2:
                let cell = tableView.cellForRow(at: indexPath) as! ReflectionDiscoverCell
            
                UIView.animate(withDuration: 0.2) {
                    cell.view.alpha = 0.5
                }
            
            default:
                print("There is no cell with that name")
                return
            
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        switch discover_users[indexPath.row].discover_style {
            case 0:
                let cell = tableView.cellForRow(at: indexPath) as! PicDiscoverCell
                
                UIView.animate(withDuration: 0.5) {
                    cell.view.alpha = 1
                }
            
            case 1:
                let cell = tableView.cellForRow(at: indexPath) as! StatusDiscoverCell
                
                UIView.animate(withDuration: 0.5) {
                    cell.view.alpha = 1
                }
            
            case 2:
                let cell = tableView.cellForRow(at: indexPath) as! ReflectionDiscoverCell
                
                UIView.animate(withDuration: 0.5) {
                    cell.view.alpha = 1
                }
            
            default:
                print("The others don't need to be animated")
                return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch discover_users[indexPath.row].discover_style{
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
        
        print(maximumOffset - currentOffset)
        
        if maximumOffset - currentOffset <= 3500 {
            
            if Internet.isOnline(){
                fetchUsers()
            }
        }
        
        
    }
}

// To update the table view from another class
protocol DiscoverUpdateDelegate {
    func didUpdate(sender: Internet)
}
