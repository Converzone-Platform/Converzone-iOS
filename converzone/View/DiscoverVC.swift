//
//  DiscoverVC.swift
//  converzone
//
//  Created by Goga Barabadze on 17.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

//MARK: BUG - First item is not shown
let names = [ "Hildegard Fox", "Chicka Chica", "Berthold-Gottfried Kaltenegger", "Riley Linus", "Beatrice Egil", "Léa Paci"]

let types = [3, 1, 2, 1, 2, 0]

class DiscoverVC: UIViewController {
    
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
        
        let searchBar = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension DiscoverVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row == 0) { return }
        
        setUpCard()
        animateTransitionIfNeeded(state: nextState, duration: 0.9)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch types[indexPath.row] {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PicDiscoverCell") as! PicDiscoverCell
            
            cell.name.text = names[indexPath.row]
            cell.profileImage.image = UIImage(named: String(arc4random_uniform(14)))
            
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
            
            cell.name.text = names[indexPath.row]
            cell.profileImage.image = UIImage(named: String(arc4random_uniform(14)))
            
            cell.profileImage.layer.cornerRadius = cell.profileImage.layer.frame.width / 2
            cell.profileImage.layer.masksToBounds = true
            cell.profileImage.contentMode = .redraw
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.status.text = "That’s why they call it the American Dream, because you have to be asleep to believe it. George Carlin -- If you’re too open-minded; your brains will fall out. Lawrence Ferlinghetti"
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReflectionDiscoverCell") as! ReflectionDiscoverCell
            
            cell.name.text = names[indexPath.row ]
            cell.profileImage.image = UIImage(named: String(arc4random_uniform(14)))
            
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
            
            cell.name.text = names[indexPath.row]
            
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
        
        switch types[indexPath.row] {
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
        switch types[indexPath.row] {
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
        
        switch (types[indexPath.row]){
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
    
}
