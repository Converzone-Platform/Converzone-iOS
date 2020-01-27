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
import Crashlytics

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
    
    private let refresh_controller = UIRefreshControl()
    
    
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
                
                Alert.alert(title: "Not yet", message: "Please talk with your partner a little more before sending one of these")
                
                return
            }
        }
        
        let actions = [
            UIAlertAction(title: "Send Image", style: .default, handler: { (alert) in
                if #available(iOS 13.0, *) {
                    alert.setValue(UIImage(systemName: "camera"), forKey: "image")
                }
            }),
            
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ]
        
        Alert.alert(title: "", message: "", target: UIApplication.currentViewController()!, actions: actions)
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
        
//        refresh_controller.addTarget(self, action: #selector(loadOldMessages( sender:)), for: .valueChanged)
//        self.tableView.refreshControl = refresh_controller
    }
   
    func didUpdate(sender: Internet, scrollToBottom: Bool) {
        DispatchQueue.main.async {
            
            //self.tableView.insertRows(at: [IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)], with: .automatic)
            
            self.tableView.reloadData()
            
            if scrollToBottom {
                self.scrollToBottom(animated: true)
            }
            
        }
    }
    
    @objc func loadOldMessages(sender: UIRefreshControl){
        
//        sender.beginRefreshing()
//
//        Internet.loadOlderMessages(sender: sender)
        
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
        
        guard let observer = listener_for_is_typing_observer else {
            os_log("Observer cannot be removed because it is already nil.")
            return
        }
        
        NotificationCenter.default.removeObserver(observer)
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
        
        chatOf.openChat()
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
        
        Internet.setImage(withURL: chatOf.link_to_profile_image, imageView: imageView)
        
        let imageWidth = label.frame.size.height * 1.3
        let imageHeight = label.frame.size.height * 1.3
        
        let imageX = label.frame.origin.x - label.frame.size.height * 1.3 - 8
        let imageY = label.frame.origin.y - 3
        
        imageView.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.roundCorners(radius: imageView.frame.width / 2, masksToBounds: true)
        
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
        
        Internet.removeListenerForIsPartnerTyping()
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
        
        return renderMessageCell(indexPath)
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                let message = chatOf.conversation[indexPath.row]
                
                switch chatOf.conversation[indexPath.row]{
                case is TextMessage:
                    
                let actions = [
                    
                    UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
                    
                    UIAlertAction(title: "Copy", style: .default) { (action) in
                        
                        UIPasteboard.general.string = (message as! TextMessage).text
                        
                    },
                    
                    UIAlertAction(title: "Speak", style: .default) { (action) in
                        
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
                        
                ]
                    
                Alert.alert(title: nil, message: nil, actions: actions)
                    
                default:
                    fatalError()
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let message = chatOf.conversation[safe: indexPath.row] else {
            return UITableView.automaticDimension
        }
        
        
        switch message {
        
        case is NeedHelpMessage: return 326
            
        default: return UITableView.automaticDimension
            
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
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //master.coordinate = manager.location!.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
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
    func didUpdate(sender: Internet, scrollToBottom: Bool)
}

extension ChatVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        
        if currentOffset < -100 {
            //Load more messages
            
//            Internet.loadMessages()
        }
    }
    
}
