//
//  DiscoverCardVC.swift
//  converzone
//
//  Created by Goga Barabadze on 01.03.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import MapKit

class DicoverCard {
    
    var discoverCard: DiscoverVC!
    var caller: UIViewController!
    
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
    
    func removeCard(){
        
        self.discoverCardVC.removeFromParent()
        self.visualEffectView.removeFromSuperview()
    }
    
    func setUpCard(caller: UIViewController) {
        
        self.caller = caller
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = caller.view.frame
        caller.view.addSubview(visualEffectView)
        
        discoverCardVC = DiscoverCardVC(nibName: "DiscoverCardVC", bundle: nil)
        
        caller.addChild(discoverCardVC)
        caller.view.addSubview(discoverCardVC.view)
        
        cardHeight = self.caller.view.frame.height
        cardHeight -= self.caller.view.frame.height * 0.10
        
        discoverCardVC.view.frame = CGRect(x: 0, y: self.caller.view.frame.height - (self.caller.navigationController?.navigationBar.frame.height)! + self.cardHandleAreaHeight - 20, width: self.caller.view.bounds.width, height: cardHeight)
        
        discoverCardVC.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(recognizer:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
        
        discoverCardVC.handleArea_view.addGestureRecognizer(tapGestureRecognizer)
        discoverCardVC.handleArea_view.addGestureRecognizer(panGestureRecognizer)
        
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
                    self.discoverCardVC.view.frame.origin.y = self.caller.view.frame.height - self.cardHeight
                case .collapsed:
                    self.discoverCardVC.view.frame.origin.y = self.caller.view.frame.height
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
                    self.caller.navigationController?.isNavigationBarHidden = true
                case .collapsed:
                    self.caller.navigationController?.isNavigationBarHidden = false
                }
                
            }
            
            navAnimation.startAnimation()
            runningAnimations.append(navAnimation)
            
            navAnimation.addCompletion { (_) in
                
                if state == .collapsed {
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
    
    
}

class DiscoverCardVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var design_view: UIView!
    @IBOutlet weak var handleArea_view: UIView!
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        design_view.layer.cornerRadius = 3
        design_view.layer.masksToBounds = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 1000
        
        self.view.backgroundColor = Colors.backgroundGrey
        handleArea_view.backgroundColor = Colors.backgroundGrey
    }
}

extension DiscoverCardVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return self.view.frame.height / 2
            
        case 1:
            // Don't show the send message button if this is opened from the chat
            if (tabBarController?.tabBar.isHidden)! {
                return 0
            }else{
                return UITableView.automaticDimension
            }
            
        //MARK: TODO - Delete this when implementing reflections
        case 6:
            return 0
        default:
            return UITableView.automaticDimension
        }
    }
    
    fileprivate func getLocationInformation(_ cell: CountryProfileCell) {
        
        locationManager.getLocation(forPlaceCalled: profileOf.country.name!) { (placemark) in
            
            cell.map.mapType = .standard
            
            let latDelta:CLLocationDegrees = 180
            let lonDelta:CLLocationDegrees = 180
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let location = CLLocationCoordinate2DMake((placemark?.coordinate.latitude)!, (placemark?.coordinate.longitude)!)
            let region = MKCoordinateRegion(center: location, span: span)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = (placemark?.coordinate)!
            
            cell.map.addAnnotation(annotation)
            cell.map.setRegion(region, animated: false)
            cell.map.setCenter((placemark?.coordinate)!, animated: true)
            
            // Time Zone
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(placemark!) { (placemarks, err) in
                if let placemark_zone = placemarks?[0] {
                    
                    cell.timezone.text = placemark_zone.timeZone?.abbreviation()
                    profileOf.timezone = (placemark_zone.timeZone?.abbreviation())!
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = Bundle.main.loadNibNamed("ImageProfileCell", owner: self, options: nil)?.first as! ImageProfileCell
            
            Internet.getImage(withURL: profileOf.link_to_profile_image) { (image) in
                cell.profileImage.image = image
            }
            
            cell.profileImage.contentMode = .scaleAspectFill
            cell.profileImage.clipsToBounds = true
            cell.profileImage.layer.cornerRadius = 23
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
        case 1:
            let cell = Bundle.main.loadNibNamed("SendMessageProfileCell", owner: self, options: nil)?.first as! SendMessageProfileCell
            
            cell.sendMessage.setTitle("Send a message", for: .normal)
            cell.sendMessage.backgroundColor = Colors.blue
            cell.sendMessage.layer.cornerRadius = 10
            cell.sendMessage.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
            
            cell.sendMessage.layer.shadowColor = UIColor.black.cgColor
            cell.sendMessage.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.sendMessage.layer.shadowOpacity = 0.2
            cell.sendMessage.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 2:
            let cell = Bundle.main.loadNibNamed("GeneralProfileCell", owner: self, options: nil)?.first as! GeneralProfileCell
            
            cell.name.text = profileOf.firstname + " " + profileOf.lastname
            
            cell.speaks.numberOfLines = 0
            cell.learning.numberOfLines = 0
            
            cell.speaks.text = addLanguagesTo(level: "Speaks", languages: profileOf.speak_languages)
            cell.learning.text = addLanguagesTo(level: "Learning", languages: profileOf.learn_languages)
        
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 3:
            let cell = Bundle.main.loadNibNamed("CountryProfileCell", owner: self, options: nil)?.first as! CountryProfileCell
            
            cell.name.text = profileOf.country.name
            cell.timezone.text = ""
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            if Internet.isOnline(){
                getLocationInformation(cell)
            }
            
            cell.map.layer.cornerRadius = 23
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 4:
            let cell = Bundle.main.loadNibNamed("StatusProfileCell", owner: self, options: nil)?.first as! StatusProfileCell
            
            cell.status.attributedText = profileOf.status
            cell.status.setLineSpacing(lineSpacing: 3, lineHeightMultiple: 2)
            cell.status.textAlignment = .center
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 5:
            let cell = Bundle.main.loadNibNamed("InterestsProfileCell", owner: self, options: nil)?.first as! InterestsProfileCell
            
            cell.interests.attributedText = profileOf.interests
            cell.interests.setLineSpacing(lineSpacing: 3, lineHeightMultiple: 2)
            cell.interests.textAlignment = .center
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
//        case 6:
//
//            let cell = Bundle.main.loadNibNamed("ReflectionProfileCell", owner: self, options: nil)?.first as! ReflectionProfileCell
//
//            cell.reflection.attributedText = profileOf!.reflections.last!.text
//            cell.reflection.setLineSpacing(lineSpacing: 3, lineHeightMultiple: 2)
//            cell.reflection.textAlignment = .center
//
//            cell.writer_of_reflection.setTitle("~" + profileOf!.reflections.first!.user_name!, for: .normal)
//
//            cell.view.layer.cornerRadius = 23
//            cell.view.layer.shadowColor = UIColor.black.cgColor
//            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
//            cell.view.layer.shadowOpacity = 0.2
//            cell.view.layer.shadowRadius = 4.0
//
//            cell.selectionStyle = .none
//
//            return cell
            
        case 7:
            let cell = Bundle.main.loadNibNamed("BlockAndReportProfileCell", owner: self, options: nil)?.first as! BlockAndReportProfileCell
            
            cell.blockAndReportOutlet.addTarget(self, action: #selector(blockandReport), for: UIControl.Event.touchUpInside)
            
            return cell
            
        default:
            print("Something bad happened while choosing the cell")
            return Bundle.main.loadNibNamed("GeneralProfileCell", owner: self, options: nil)?.first as! GeneralProfileCell
        }
        
        
    }
    
    @objc func handleSendMessage(){
        
        // Does this user already exist?
        let userExists = master.conversations.last(where: {$0.uid == profileOf.uid})
        
        if userExists == nil{
            let info = FirstInformationMessage()
            
            info.date = Date()
            
            profileOf.conversation.append(info)
            
            master.conversations.append(profileOf)
        }
        
        // Find the right index of the chat
        var index = 0
            
        for user in master.conversations {
            if user.uid == profileOf.uid {
                indexOfUser = index
            }
            
            index+=1
        }
        
        Navigation.push(viewController: "ChatVC", context: self.tabBarController?.viewControllers?[0] as! UINavigationController)
        
        self.tabBarController?.selectedIndex = 0
        
    }
    
    @objc func blockandReport(){
        let alertController = UIAlertController(title: "What do you want to do?",
                                                message: "Please help us make our platform a little better. Choose 'Block' if it is something personal and 'Block and Report' if it is something that others might dislike too",
                                                preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let blockAndReport = UIAlertAction(title: "Report", style: .destructive) { (action) in
            
            self.report(title: "Report user", message: "Tell us why you want to report this user.")
        }
        alertController.addAction(blockAndReport)
        
        let block = UIAlertAction(title: "Block", style: .destructive) { (action) in
        
            Internet.block(userid: profileOf.uid)
            
        }
        
        alertController.addAction(block)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addLanguagesTo(level: String, languages: [Language]) -> String{
        
        if languages.count == 0{
            return ""
        }
        
        var new_label = level + ": "
        
        for i in 0...languages.endIndex-1 {
            
            if i == languages.endIndex-1 && languages.count > 1{
                new_label += " & "
            }else{
                if i != 0{
                    new_label += ", "
                }
            }
            
            new_label += languages[i].name
        }
        
        return new_label
    }
    
    func report(title: String, message: String) {
        
        var saveTextField: UITextField? = nil
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "Send", style: .default) { (alertAction) in
            saveTextField = alert.textFields![0] as UITextField
            
            Internet.report(userid: profileOf.uid, reason: saveTextField!.text!)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Describe what's wrong"
            saveTextField = textField
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }
}

