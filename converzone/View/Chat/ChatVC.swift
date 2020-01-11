//
//  ChatVC.swift
//  converzone
//
//  Created by Goga Barabadze on 01.03.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import os
import MathParser

var chatOf: User = User()

class ChatVC: UIViewController, ChatUpdateDelegate {
    
    @IBOutlet weak var message_input_height_constraint: UIView!
    @IBOutlet weak var message_input_bottom_constraint: NSLayoutConstraint!
    @IBOutlet weak var input_message: UIView!
    
    @IBOutlet weak var input_textview: UITextView!
    
    @IBOutlet weak var send_outlet: UIButton!
    
    @IBOutlet weak var progress_indicator: UIProgressView!
    
    
    var discover_card: DicoverCard!
    var tapGestureRecognizer: UITapGestureRecognizer!
    let updates = Internet()
    let locationManager = CLLocationManager()
    
    @IBAction func send(_ sender: Any) {
        
        guard var text = input_textview.text else {
            os_log("User is trying to send a message without any content")
            return
        }
        
        Internet.stoppedTyping(uid: chatOf.uid)
        
        deleteFirstMessage()

        text = text.replacingOccurrences(of: "fuck", with: "🦆", options: .caseInsensitive, range: nil)
        
        let message = TextMessage(text: text, is_sender: true)
        Internet.send(message: message, receiver: chatOf)

        guard let last = text.last else {
            return
        }
        
        if last == "=" {
            if let exp = Parser.parse(string: text){
                if let value = exp.evaluate() {
                    let math = InformationMessage()
                    
                    math.date = Date()
                    math.is_sender = true
                    math.text = String(describing: value)
                    
                    Internet.send(message: math, receiver: chatOf)
                }
            }
        }
        
        input_textview.text = ""
        message_input_height_constraint.constraints.first?.constant = input_textview.contentSize.height + 16
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.send_outlet.alpha = 0
        }, completion: nil)
    }
    
    @IBAction func more_button(_ sender: Any) {
        
        // Is this supposed to be the one of the first messages?
        if chatOf.conversation[0] is FirstInformationMessage{
            
            let message = chatOf.conversation[0] as! FirstInformationMessage
            
            if message.text == "Be creative with the first message :)"{
                alert("Not yet", "Please talk with your partner a little more before sending one of these")
                return
            }
        }
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view // to set the source of your alert
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        
        alert.addAction(UIAlertAction(title: "Send image", style: .default, handler: { (alert_action) in
            if #available(iOS 13.0, *) {
                alert_action.setValue(UIImage(systemName: "camera"), forKey: "image")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private func deleteFirstMessage() {
        if chatOf.conversation.first is FirstInformationMessage {
            chatOf.conversation.remove(at: 0)
            self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpObervers()
        
        input_textview.delegate = self
        
        setUpInfoButton()
        
        navigationItem.titleView = navTitleWithImageAndText(titleText: chatOf.fullname, imageLink: chatOf.link_to_profile_image)
        
        Internet.update_chat_tableview_delegate = self
    }
   
    func didUpdate(sender: Internet) {
        DispatchQueue.main.async {
            
            //self.tableView.insertRows(at: [IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)], with: .automatic)
            
            self.tableView.reloadData()
            
            self.scrollToBottom(animated: true)
        }
    }
    
    private var is_partner_typing_timer: Timer? = nil
    
    func partnerStartedTyping(){
        
        is_partner_typing_timer?.invalidate()
        is_partner_typing_timer = nil
        
        UIView.animate(withDuration: 0.5) {
            self.progress_indicator.alpha = 1
        }
        
        is_partner_typing_timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { (timer) in
            UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                let random = Colors.random()
                self.progress_indicator.progressTintColor = random
                self.input_textview.tintColor = random
            })
        })
        
    }
    
    func partnerStoppedTyping(){
        is_partner_typing_timer?.invalidate()
        is_partner_typing_timer = nil
        
        UIView.animate(withDuration: 0.5) {
            self.progress_indicator.alpha = 0
            self.input_textview.tintColor = .blue
        }
    }
    
    private var listener_for_is_typing_observer: NSObjectProtocol!
    
    deinit {
        NotificationCenter.default.removeObserver(listener_for_is_typing_observer!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listener_for_is_typing_observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "listener_for_is_partner_typing"), object: nil, queue: .main) { [weak self] notification in
            
            if Internet.is_partner_typing {
                self?.partnerStartedTyping()
            }else{
                self?.partnerStoppedTyping()
            }
        }
        
        input_textview.text = chatOf.unfinished_message
        
        ConversationsVC().title = ""
        
        Internet.listenForIsTyping(uid: chatOf.uid)
        
        setUpLocationServices()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.tableView.reloadData()
        scrollToBottom(animated: false)
        
        // Add gesture recognizer to the navigation bar when the view is about to appear
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.showMoreOfPartner(_:)))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        
        // This allows controlls in the navigation bar to continue receiving touches
        tapGestureRecognizer.cancelsTouchesInView = false
        
        getNotificationPermissionFromUser()
        
        chatOf.openChat()
    }
    
    /// Ask if we can send notifications to this device
    private func getNotificationPermissionFromUser() {
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (bool, error) in
            
            Internet.upload(token: Internet.fcm_token)
            
        }
    }
    
    @objc private func goToConversations(){
        
        Navigation.push(viewController: "ConversationsVC", context: self)
    }
    
    private func navTitleWithImageAndText(titleText: NSAttributedString, imageLink: String) -> UIView {
        
        // Creates a new UIView
        let titleView = UIView()
        
        // Creates a new text label
        let label = UILabel()
        label.attributedText = titleText
        label.sizeToFit()
        label.center = titleView.center
        label.textAlignment = NSTextAlignment.center
        
        // Creates the image view
        let imageView = UIImageView()
        
        Internet.getImage(withURL: chatOf.link_to_profile_image) { (image) in
            imageView.image = image
        }
        
        let imageWidth = label.frame.size.height * 1.3
        let imageHeight = label.frame.size.height * 1.3
        
        let imageX = label.frame.origin.x - label.frame.size.height * 1.3 - 8
        let imageY = label.frame.origin.y - 3
        
        imageView.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        
        // Adds both the label and image view to the titleView
        titleView.addSubview(label)
        titleView.addSubview(imageView)
        
        // Sets the titleView frame to fit within the UINavigation Title
        titleView.sizeToFit()
        
        return titleView
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Internet.stoppedTyping(uid: chatOf.uid)
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.navigationBar.removeGestureRecognizer(tapGestureRecognizer)
        
        chatOf.unfinished_message = input_textview.text
        
        chatOf = User()
        
    }
    
    
    private func setUpInfoButton(){
//        if #available(iOS 13.0, *) {
//            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipses.circle"), style: .plain, target: self, action: #selector(handleInfoButton))
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
    @objc private func handleInfoButton(){
        //Go to next view controller
        Navigation.push(viewController: "ChatSettingsVC", context: self)
    }
    
    private func setUpTableView(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 1000
        
        tableView.backgroundColor = Colors.background_grey
    }
    
    private func setUpObervers(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func showMoreOfPartner(_ sender: UITapGestureRecognizer){

        // Make sure that a button is not tapped.
        let location = sender.location(in: self.navigationController?.navigationBar)
        let hitView = self.navigationController?.navigationBar.hitTest(location, with: nil)
        
        guard !(hitView is UIControl) else { return }
        
        profile_of = chatOf
        
        self.discover_card = DicoverCard()
        self.discover_card.setUpCard(caller: self)
        self.discover_card.animateTransitionIfNeeded(state: self.discover_card.nextState, duration: 0.9)
        
        view.endEditing(true)
        self.loadViewIfNeeded()
    }
    
    @objc private func handleKeyboard(_ notification: Notification){
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let newHeight: CGFloat
            let duration:TimeInterval = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            
            
            let animationCurveRawNSN = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            
            newHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
            
            let keyboardHeight = newHeight
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            self.message_input_bottom_constraint.constant = keyboardHeight
                            
                            self.view.layoutIfNeeded()
                            
            },
                           completion: nil)
        }
        
        self.scrollToBottom(animated: true)
        
    }
    
    private func updateTableView(animated: Bool){
        
        let indexPath = NSIndexPath(row: tableView.numberOfRows(inSection: 0), section: 0) as IndexPath
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        
        scrollToBottom(animated: true)
    }
    
    private func scrollToBottom(animated: Bool = true, delay: Double = 0.0) {
        let numberOfRows = tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 1
        guard numberOfRows > 0 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
            
            let indexPath = IndexPath(
                row: numberOfRows,
                section: self.tableView.numberOfSections - 1)
            
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    @objc private func didTakeScreenshot(){
        
        let screenshot_message = InformationMessage()
        
        screenshot_message.text = master.fullname.string + " screenshoted the chat"
        screenshot_message.date = Date()
        screenshot_message.is_sender = true
        
        Internet.send(message: screenshot_message, receiver: chatOf)
        
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatOf.conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row >= chatOf.conversation.count {
            return UITableViewCell()
        }
        
        switch chatOf.conversation[indexPath.row]{
            
        case is TextMessage:
            
            let cell = Bundle.main.loadNibNamed("TextMessageCell", owner: self, options: nil)?.first as! TextMessageCell
            
            let message = chatOf.conversation[indexPath.row] as! TextMessage
            
            // Add Long pressure gesture
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
            cell.addGestureRecognizer(longPressRecognizer)
            
            cell.message_label.text = message.text
            cell.selectionStyle = .none
            
            if message.only_emojies == false {
                
                if message.is_sender == true{
                    cell.message_label.textColor = Colors.white
                    cell.view.backgroundColor = Colors.blue
                }else{
                    cell.message_label.textColor = Colors.black
                    cell.view.backgroundColor = Colors.white
                }
                
                cell.view.layer.cornerRadius = 18
                cell.view.layer.shadowColor = UIColor.black.cgColor
                cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
                cell.view.layer.shadowOpacity = 0.2
                cell.view.layer.shadowRadius = 4.0
                
            }else{
                if message.text.count <= 5{
                    cell.message_label.font = UIFont.systemFont(ofSize: 50)
                }else{
                    cell.message_label.font = UIFont.systemFont(ofSize: 30)
                }
            }
            
            if  message.is_sender == true {
                
                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
                
                cell.message_label.textAlignment = .right
                
                if ((cell.message_label.text?.widthWithConstrained(cell.message_label.frame.height, font: cell.message_label.font))! <= self.view.frame.width - (2 * 36)){
                    cell.left_constraint.isActive = false
                }
                
            }else{
                
                if message.only_emojies == false {
                    cell.view.backgroundColor = Colors.white
                    cell.message_label.textColor = Colors.black
                }
                
                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                
                cell.message_label.textAlignment = .left
                if ((cell.message_label.text?.widthWithConstrained(cell.message_label.frame.height, font: cell.message_label.font))! <= self.view.frame.width - (2 * 36)){
                    cell.right_constraint.isActive = false
                }
            }
            
            var cornerToConnect = CACornerMask.layerMaxXMinYCorner
            var cornerToConnect2 = CACornerMask.layerMaxXMaxYCorner
            
            if message.is_sender == false {
                cornerToConnect = .layerMinXMinYCorner
                cornerToConnect2 = .layerMinXMaxYCorner
            }
            
            if let last_message = chatOf.conversation[safe: indexPath.row - 1] {
                if last_message.is_sender == message.is_sender{
                    cell.top_constraint.constant = 3
                    
                    cell.view.layer.maskedCorners.remove(cornerToConnect)
                }
            }
            
            if let next_message = chatOf.conversation[safe: indexPath.row + 1] {
                if next_message.is_sender == message.is_sender{
                    cell.bottom_constraint.constant = 3
                    
//                    cell.view.layer.maskedCorners.remove(.layerMaxXMaxYCorner)
//                    cell.view.layer.maskedCorners.remove(.layerMaxXMinYCorner)
//                    cell.view.layer.maskedCorners.remove(.layerMinXMaxYCorner)
//                    cell.view.layer.maskedCorners.remove(.layerMinXMinYCorner)
                }else{
                    cell.view.layer.maskedCorners.insert(cornerToConnect2)
                }
            }else{
                cell.view.layer.maskedCorners.insert(cornerToConnect2)
                
            }
            
            return cell
            
//        case is ImageMessage:
//
//            let cell = Bundle.main.loadNibNamed("ImageMessageCell", owner: self, options: nil)?.first as! ImageMessageCell
//
//            let message = chatOf.conversation[indexPath.row] as! ImageMessage
//
//            cell.message_imageView.image = message.image
//            cell.message_imageView.contentMode = .scaleAspectFill
//            cell.message_imageView.clipsToBounds = true
//            cell.message_imageView.layer.cornerRadius = 23
//
//            cell.view.layer.cornerRadius = 23
//            cell.view.layer.shadowColor = UIColor.black.cgColor
//            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
//            cell.view.layer.shadowOpacity = 0.2
//            cell.view.layer.shadowRadius = 4.0
//
//            cell.selectionStyle = .none
//
//            if  message.is_sender == true {
//
//                cell.message_imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
//
//                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
//
//            }else{
//                cell.message_imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
//
//                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
//            }
//
//            return cell
//
//        case is LocationMessage:
//
//            let cell = Bundle.main.loadNibNamed("LocationMessageCell", owner: self, options: nil)?.first as! LocationMessageCell
//
//            let message = chatOf.conversation[indexPath.row] as! LocationMessage
//            let latitude: CLLocationDegrees = (message.coordinate?.latitude)!
//            let longitude: CLLocationDegrees = (message.coordinate?.longitude)!
//
//            let latDelta:CLLocationDegrees = 0.01
//            let lonDelta:CLLocationDegrees = 0.01
//
//            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
//            let location = CLLocationCoordinate2DMake(latitude, longitude)
//            let region = MKCoordinateRegion(center: location, span: span)
//
//            let annotation = MKPointAnnotation()
//
//            annotation.coordinate = message.coordinate!
//
//            if message.is_sender {
//                annotation.title = master.fullname.string
//            }else{
//                annotation.title = chatOf.fullname.string
//            }
//
//            cell.map.addAnnotation(annotation)
//            cell.map.setRegion(region, animated: false)
//
//            cell.map.setCenter(message.coordinate!, animated: true)
//
//            cell.map.layer.cornerRadius = 23
//            cell.view.layer.cornerRadius = 23
//            cell.view.layer.shadowColor = UIColor.black.cgColor
//            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
//            cell.view.layer.shadowOpacity = 0.2
//            cell.view.layer.shadowRadius = 4.0
//
//            cell.selectionStyle = .none
//
//            if  message.is_sender == true {
//
//                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
//                cell.map.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
//            }else{
//
//                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
//                cell.map.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
//            }
//
//            return cell
            
        case is FirstInformationMessage:
            fallthrough
        case is InformationMessage:
            let cell = Bundle.main.loadNibNamed("InformationMessageCell", owner: self, options: nil)?.first as! InformationMessageCell
            let message = chatOf.conversation[indexPath.row] as! InformationMessage
            
            cell.information.text = message.text
            
            cell.view.layer.cornerRadius = 15
            
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case is NeedHelpMessage:
            let cell = Bundle.main.loadNibNamed("NeedHelpMessageCell", owner: self, options: nil)?.first as! NeedHelpMessageCell
            
            cell.title.text = "Need some help?"
            cell.message.text = "We have noticed that your partner acts a little weird."
            
            cell.backgroundColor = .clear
            
            cell.view.layer.cornerRadius = 15

            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0

            cell.selectionStyle = .none
            
            return cell
            
        default:
            print("that is a new kind of message")
        }
        return Bundle.main.loadNibNamed("ImageMessageCell", owner: self, options: nil)?.first as! ImageMessageCell
    }
    
    @objc private func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                let message = chatOf.conversation[indexPath.row]
                
                switch chatOf.conversation[indexPath.row]{
                case is TextMessage:
                    
                let alertController = UIAlertController(title: nil,
                                                            message: nil,
                                                            preferredStyle: .actionSheet)
                    
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view // to set the source of your alert
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
                    popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let copy = UIAlertAction(title: "Copy", style: .default) { (action) in
                    
                    UIPasteboard.general.string = (message as! TextMessage).text
                    
                }
                let speak = UIAlertAction(title: "Speak", style: .default) { (action) in
                    
                    // Line 1. Create an instance of AVSpeechSynthesizer.
                    let speechSynthesizer = AVSpeechSynthesizer()
                    let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: (message as! TextMessage).text)
                    if let language = NSLinguisticTagger.dominantLanguage(for: (message as! TextMessage).text) {
                        speechUtterance.voice = AVSpeechSynthesisVoice(language: language)
                    } else {
                        speechUtterance.voice = AVSpeechSynthesisVoice(language: Locale.preferredLanguages[0])
                    }
                    
                    // Line 5. Pass in the urrerance to the synthesizer to actually speak.
                    speechSynthesizer.speak(speechUtterance)
                    
                }
                    
                alertController.addAction(speak)
                alertController.addAction(copy)
                
                self.present(alertController, animated: true, completion: nil)
                
                    
                default:
                    fatalError()
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if chatOf.conversation.isEmpty {
            return UITableView.automaticDimension
        }
        
        switch chatOf.conversation[indexPath.row]{
            
//        case is ImageMessage:
//            if self.view.frame.width < self.view.frame.height{
//                return self.view.frame.width
//            }
//
//            return self.view.frame.height
//
//        case is LocationMessage:
//
//            if self.view.frame.width < self.view.frame.height {
//                return self.view.frame.width
//            }
//
//            return self.view.frame.height
            
        case is NeedHelpMessage:
            return 326
            
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Direct to maps if the message is a location
//        if chatOf.conversation[indexPath.row] is LocationMessage {
//            let message = chatOf.conversation[indexPath.row] as! LocationMessage
//            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (message.coordinate?.latitude)!, longitude: (message.coordinate?.longitude)!))
//
//            let source = MKMapItem(placemark: placemark)
//
//            if message.is_sender {
//                source.name = master.fullname.string
//            }else{
//                source.name = chatOf.fullname.string
//            }
//
//            MKMapItem.openMaps(with: [source], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
//
//        }
    }
    
    
}

// MARK: Send message

extension ChatVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        message_input_height_constraint.constraints.first?.constant = textView.contentSize.height + 16
        
        if !(Internet.is_typing_timer?.isValid ?? false) {
            Internet.startedTyping(uid: chatOf.uid)
        } else if textView.text.count == 0 {
            Internet.stoppedTyping(uid: chatOf.uid)
        }
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.send_outlet.alpha = 0
            }, completion: nil)
            
        }else{
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.send_outlet.alpha = 1
            }, completion: nil)
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        message_input_bottom_constraint.constant = 0
        
        Internet.stoppedTyping(uid: chatOf.uid)
    }
}

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func getImageFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.photoLibrary
            image.mediaTypes = [/*"public.movie",*/ "public.image"]
            image.allowsEditing = true
            self.present(image, animated: true, completion: nil)
        }
    }
    
    private func getImageFromCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.camera
            image.mediaTypes = [/*"public.movie",*/ "public.image"]
            image.allowsEditing = true
            image.cameraCaptureMode = .photo
            self.present(image, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
//            os_log("Could not extract image.")
//            return
//        }
//
//        let message = ImageMessage(image: image, is_sender: true)
//        chatOf.conversation.append(message)
//
//        updateTableView(animated: true)
//
//        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ChatVC: CLLocationManagerDelegate {
    func setUpLocationServices(){
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //master.coordinate = manager.location!.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
}

//Disable Auto Rotation
extension ChatVC {
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .portrait
    }
    
}

// To update the table view from another class
protocol ChatUpdateDelegate {
    func didUpdate(sender: Internet)
}
