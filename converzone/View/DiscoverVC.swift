//
//  DiscoverVC.swift
//  converzone
//
//  Created by Goga Barabadze on 17.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

let numberOfItemsPerFetch = 7

var discover_users: [User] = []

var profileOf: User? = nil

class DiscoverVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var discoverCardVC: DiscoverCardVC!
    var visualEffectView: UIVisualEffectView!
    
    var cardHeight: CGFloat = 600
    let cardHandleAreaHeight: CGFloat = 30
    
    var cardVisible = false
    var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProcessWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar()
        
        self.view.backgroundColor = Colors.backgroundGrey
        
        fetchUsers()
        
    }
    
    func fetchUsers(){
        Internet.databaseWithMultibleReturn(url: baseURL + "/discover.php", parameters: ["min_id" : discover_users.count + 1, "max_id": discover_users.count + numberOfItemsPerFetch]) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
            }
            
            //Did the server give back an error?
            if let httpResponse = response as? HTTPURLResponse {
                
                DispatchQueue.main.async {
                    if !(httpResponse.statusCode == 200) {
                        
                        print(httpResponse.statusCode)
                    }else{
                        
                        var temp: [User] = []
                        
                        for i in data! {
                            let user = User()
                            
                            user.firstname = i["FIRSTNAME"] as? String
                            user.lastname = i["LASTNAME"] as? String
                            user.link_to_profile_image = i["PROFILE_PICTURE_URL"] as? String
                            
                            if let str = i["USERID"] as? String, let uid = Int(str) {
                                user.uid = uid
                            }
                            
                            user.interests = NSAttributedString(string: (i["INTERESTS"] as? String)!)
                            user.status = NSAttributedString(string: (i["STATUS"] as? String)!)
                            user.country = Country(name: (i["COUNTRY"] as? String)!)
                            
                            if Int(arc4random_uniform(100)) <= 10{
                                user.discover_style = 1
                            }else{
                                user.discover_style = 0
                            }
                            
                            // Get languages
                            Internet.databaseWithMultibleReturn(url: baseURL + "/languages.php", parameters: ["id": user.uid! as Any], completionHandler: { (languages, response, error) in
                                
                                if let httpResponse = response as? HTTPURLResponse {
                                    
                                    if !(httpResponse.statusCode == 200) {
                                        
                                        print(httpResponse.statusCode)
                                    }
                                    
                                }
                                
                                if languages != nil{
                                    
                                    for language in languages!{
                                        
                                        let languageToAdd = Language(name: (language["LANGUAGE"] as? String)!)
                                        
                                        if language["PROFICIENCY"] as? String == "l"{
                                            user.learn_languages.append(languageToAdd)
                                        }else{
                                            user.speak_languages.append(languageToAdd)
                                        }
                                        
                                    }
                                }
                                
                            })
                            
                            user.reflections.append(Reflection(text: NSAttributedString(string: ""), user_name: "", user_id: "1", date: Date()))
                            
                            temp.append(user)
                        }
                        
                        //temp.sort(by: {_,_ in arc4random() % 2 == 0})
                        temp.shuffle()
                        
                        discover_users.append(contentsOf: temp)
                        
                        self.tableView.reloadData()
                        
                    }
                }
            }
        }
    }
    
    func removeCard(){
        
        self.discoverCardVC.removeFromParent()
        self.visualEffectView.removeFromSuperview()
    }
    
    func setUpCard() {
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        discoverCardVC = DiscoverCardVC(nibName: "DiscoverCardVC", bundle: nil)
        
        self.addChild(discoverCardVC)
        self.view.addSubview(discoverCardVC.view)
        
        discoverCardVC.view.frame = CGRect(x: 0, y: self.view.frame.height - (self.navigationController?.navigationBar.frame.height)! + self.cardHandleAreaHeight - 20, width: self.view.bounds.width, height: cardHeight)
       
        
        discoverCardVC.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DiscoverVC.handleCardTap(recognizer:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DiscoverVC.handleCardPan(recognizer:)))
        
        discoverCardVC.handleArea_view.addGestureRecognizer(tapGestureRecognizer)
        discoverCardVC.handleArea_view.addGestureRecognizer(panGestureRecognizer)
        
        cardHeight = self.view.frame.height - 30
        
        animateTransitionIfNeeded(state: .expanded, duration: 0.9)
    }
    
    @objc func handleCardTap(recognizer: UITapGestureRecognizer ){
        
        switch recognizer.state {
            
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
        
    }
    
    @objc func handleCardPan(recognizer: UIPanGestureRecognizer ) {
        
        switch recognizer.state {
            
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
            
        case .changed:
            let transition = recognizer.translation(in: self.discoverCardVC.handleArea_view)
            var fractionCompleted = transition.y / cardHeight
            fractionCompleted = cardVisible ? fractionCompleted : -fractionCompleted
            updateInteractiveTransition(fractionCompleted: fractionCompleted)
            
        case .ended:
            continueInteractiveTransition()
            
        default:
            print("Something bad happened with the handleCardPan")
            break
            
        }
    }
    
    func animateTransitionIfNeeded(state: CardState, duration: TimeInterval){
        
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                
                switch state {
                case .expanded:
                    self.discoverCardVC.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.discoverCardVC.view.frame.origin.y = self.view.frame.height
                }
            }
            
            frameAnimator.addCompletion { (_) in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                
                switch state {
                case .expanded:
                    self.discoverCardVC.view.layer.cornerRadius = 23
                    self.discoverCardVC.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                case .collapsed:
                    self.discoverCardVC.view.layer.cornerRadius = 0
                }
                
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
                
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
            let navAnimation = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
                
                switch state {
                case .expanded:
                    self.navigationController?.isNavigationBarHidden = true
                case .collapsed:
                    self.navigationController?.isNavigationBarHidden = false
                }
                
            }
            
            navAnimation.startAnimation()
            runningAnimations.append(navAnimation)
            
            navAnimation.addCompletion { (_) in
                
                if( state == .collapsed ){
                    self.removeCard()
                }
                
            }
        }
        
    }
        
    func startInteractiveTransition(state: CardState, duration: TimeInterval){
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProcessWhenInterrupted = animator.fractionComplete
        }
    }
    
    func  updateInteractiveTransition(fractionCompleted: CGFloat){
        
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProcessWhenInterrupted
        }
    }
    
    func continueInteractiveTransition(){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    func setUpNavBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // This is not finished yet
//        let searchBar = UISearchController(searchResultsController: nil)
//        navigationItem.searchController = searchBar
//        navigationItem.hidesSearchBarWhenScrolling = false
        
        //let filter_button = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Button text for Filter Discover"), style: .plain, target: self, action: nil)
    }
}

extension DiscoverVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //if (types[indexPath.row] == 3) { return }
        
        profileOf = discover_users[indexPath.row]
        
        setUpCard()
        animateTransitionIfNeeded(state: nextState, duration: 0.9)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if discover_users.count != 0{
            
            //self.tableView.backgroundView = nil
            
            return discover_users.count
        }
        
//        let noDataLabel: UILabel = UILabel(frame: CGRect(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
//
//        noDataLabel.text = "No one here? Weird..."
//        noDataLabel.numberOfLines = 0
//
//        noDataLabel.textColor = Colors.black
//        noDataLabel.textAlignment = NSTextAlignment.center
//        self.tableView.backgroundView = noDataLabel
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch discover_users[indexPath.row].discover_style {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PicDiscoverCell") as! PicDiscoverCell
            
            cell.name.text = discover_users[indexPath.row].fullname
            
            discover_users[indexPath.row].getImage(with: discover_users[indexPath.row].link_to_profile_image!, completion: { (image) in
                cell.profileImage.image = image
            })
            
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
            discover_users[indexPath.row].getImage(with: discover_users[indexPath.row].link_to_profile_image!, completion: { (image) in
                cell.profileImage.image = image
            })
            
            cell.profileImage.layer.cornerRadius = cell.profileImage.layer.frame.width / 2
            cell.profileImage.layer.masksToBounds = true
            cell.profileImage.contentMode = .redraw
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.status.text = discover_users[indexPath.row].status?.string
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReflectionDiscoverCell") as! ReflectionDiscoverCell
            
            cell.name.text = discover_users[indexPath.row].fullname
            discover_users[indexPath.row].getImage(with: discover_users[indexPath.row].link_to_profile_image!, completion: { (image) in
                cell.profileImage.image = image
            })
            
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
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 5.0 {
            
            fetchUsers()
        }
    }
}
