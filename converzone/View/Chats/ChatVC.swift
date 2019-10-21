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

var indexOfUser: Int = 0

class ChatVC: UIViewController, ChatUpdateDelegate {
    
    @IBOutlet weak var messageInputBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputMessage: UIView!
    @IBOutlet weak var message_textField: UITextField!
    
    var discoverCard: DicoverCard!
    
    // Declare gesture recognizer
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    // To update the table view from the Internet class
    let updates = Internet()
    
    //Location purposes
    let locationManager = CLLocationManager()
    
    @IBAction func audio_button(_ sender: Any) {
        print("Send audio message")
    }
    
    fileprivate func deleteFirstMessage() {
        // Let's delete the FirstInformationMessage in case we haven't already
        if master.conversations[indexOfUser].conversation.first is FirstInformationMessage {
            _ = master.conversations[indexOfUser].conversation.removeAll(where: { (message) -> Bool in
                return message is FirstInformationMessage
            })
            self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
    @IBAction func more_button(_ sender: Any) {
        
        // Is this supposed to be the one of the first messages?
        if master.conversations[indexOfUser].conversation[0] is FirstInformationMessage{
            
            let message = master.conversations[indexOfUser].conversation[0] as! FirstInformationMessage
            
            if message.text == "Be creative with the first message :)"{
                alert("Not yet", "Please talk with your partner a little more before sending one of these", self)
                return
            }
        }
        
        let location_alert = UIAlertController()
        
        
//        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
//
//            self.getImageFromCamera()
//            self.deleteFirstMessage()
//        }))
        
//        alert.addAction(UIAlertAction(title: "Photo or Video", style: .default , handler:{ (UIAlertAction)in
//
//            self.getImageFromLibrary()
//            self.deleteFirstMessage()
//        }))
        
//        alert.addAction(UIAlertAction(title: "Contact", style: .default , handler:{ (UIAlertAction)in
//
//              self.deleteFirstMessage()
//
//        }))
//
        
        location_alert.addAction(UIAlertAction(title: "Location", style: .default , handler:{ (UIAlertAction)in

            self.setUpLocationServices()
            
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                
                    alert("No access to the location services", "Please go into the settings and enable the location services for this app. You can chose \"always\" or just \"when in use\" there.", self)
                    
                    
                case .authorizedAlways, .authorizedWhenInUse:

                    let locationMessage = LocationMessage()
                    locationMessage.is_sender = true

                    self.locationManager.requestLocation()
                    locationMessage.coordinate = master.coordinate
                    locationMessage.date = Date()

                    master.conversations[indexOfUser].conversation.append(locationMessage)

                    self.updateTableView(animated: true)
                    
                    self.deleteFirstMessage()

                default:
                    print("That's weird. Check me out. I am on line: ", #line)
                }
            } else {
                print("Location services are not enabled")
            }
        }))
        
        location_alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        self.present(location_alert, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        setUpMessageTextField()
        setUpObervers()
        
        message_textField.delegate = self
        
        //setUpInfoButton()
        
        navigationItem.titleView = navTitleWithImageAndText(titleText: master.conversations[indexOfUser].fullname!, imageLink: master.conversations[indexOfUser].link_to_profile_image!)
        
        updates.chat_delegate = self
        
        master.conversations[indexOfUser].openedChat = true
        
        
        
    }
   
    func didUpdate(sender: Internet) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    }
    
    @objc func goToConversations(){
        
        Navigation.push(viewController: "ConversationsVC", context: self)
    }
    
    func navTitleWithImageAndText(titleText: String, imageLink: String) -> UIView {
        
        // Creates a new UIView
        let titleView = UIView()
        
        // Creates a new text label
        let label = UILabel()
        label.text = titleText
        label.sizeToFit()
        label.center = titleView.center
        label.textAlignment = NSTextAlignment.center
        
        // Creates the image view
        let imageView = UIImageView()
        
        // MARK: TODO - Download image
        
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
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.navigationController?.navigationBar.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func setUpInfoButton(){
        let infoButton = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(handleInfoButton))
        navigationItem.rightBarButtonItem = infoButton
    }
    
    @objc func handleInfoButton(){
        //Go to next view controller
        Navigation.push(viewController: "ChatSettingsVC", context: self)
    }
    
    func setUpTableView(){
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 1000
        
        tableView.backgroundColor = Colors.backgroundGrey
    }
    
    func setUpObervers(){
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        
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
    
    @objc func showMoreOfPartner(_ sender: UITapGestureRecognizer){

        // Make sure that a button is not tapped.
        let location = sender.location(in: self.navigationController?.navigationBar)
        let hitView = self.navigationController?.navigationBar.hitTest(location, with: nil)
        
        guard !(hitView is UIControl) else { return }
        
        self.discoverCard = DicoverCard()
        self.discoverCard.setUpCard(caller: self)
        self.discoverCard.animateTransitionIfNeeded(state: self.discoverCard.nextState, duration: 0.9)
        
        view.endEditing(true)
        self.loadViewIfNeeded()
    }
    
    func setUpMessageTextField(){
        let amountOfLinesToBeShown: CGFloat = 6
        let maxHeight: CGFloat = message_textField.font!.lineHeight * amountOfLinesToBeShown
        message_textField.sizeThatFits(CGSize(width: message_textField.frame.size.width, height: maxHeight))
    }
    
    @objc func handleKeyboard(_ notification: Notification){
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let newHeight: CGFloat
            let duration:TimeInterval = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            
            newHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
            
            let keyboardHeight = newHeight /*+ 10*/ // **10 is bottom margin of View**  and **this newHeight will be keyboard height**
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            self.messageInputBottomConstraint.constant = keyboardHeight
                            
                            self.view.layoutIfNeeded()
                            
            },
                           completion: nil)
        }
        
        self.scrollToBottom(animated: true)
        
    }
    
    func updateTableView(animated: Bool){
        
        let indexPath = NSIndexPath(row: tableView.numberOfRows(inSection: 0), section: 0) as IndexPath
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        
        scrollToBottom(animated: true)
    }
    
    func scrollToBottom(animated: Bool = true, delay: Double = 0.0) {
        let numberOfRows = tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 1
        guard numberOfRows > 0 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
            
            let indexPath = IndexPath(
                row: numberOfRows,
                section: self.tableView.numberOfSections - 1)
            
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    @objc func didTakeScreenshot(){
        
//        let screenshot_message = InformationMessage()
//
//        screenshot_message.text = NSLocalizedString("You", comment: "The pronoun") + " " + NSLocalizedString("took a screenshot!", comment: "Message when the master or the partner takes a screenshot")
//        screenshot_message.date = NSDate() as Date
//
//        master?.conversations[indexOfUser].conversation.append(screenshot_message)
//
//        //MARK: TODO - Send this to the partner
//
//        updateTableView(animated: true)
        
    }
    
    func animateBubbleWithRainbowColors(times: Int, cell: TextMessageCell){
        
        if times == 0{
            return
        }
        
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            cell.view.backgroundColor = randomColor()
        }) { (finished) in
            self.animateBubbleWithRainbowColors(times: times-1, cell: cell)
        }
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (master.conversations[indexOfUser].conversation.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch master.conversations[indexOfUser].conversation[indexPath.row]{
            
        case is TextMessage:
            
            let cell = Bundle.main.loadNibNamed("TextMessageCell", owner: self, options: nil)?.first as! TextMessageCell
            
            let message = master.conversations[indexOfUser].conversation[indexPath.row] as! TextMessage
            
            // Add Long pressure gesture
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
            cell.addGestureRecognizer(longPressRecognizer)
            
            cell.message_label.attributedText = message.text!
            cell.selectionStyle = .none
            
            if (message.only_emojies == false){
                
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
                
                if message.text!.string.count <= 5{
                    cell.message_label.font = UIFont.systemFont(ofSize: 50)
                }else{
                    cell.message_label.font = UIFont.systemFont(ofSize: 30)
                }
            }
            
            if  message.is_sender == true {
                
                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
                
                cell.message_label.textAlignment = .right
                
                if ((cell.message_label.text?.widthWithConstrained(cell.message_label.frame.height, font: cell.message_label.font))! <= self.view.frame.width - (2 * 36)){
                    cell.leftConstraint.isActive = false
                    
                    if (cell.message_label.text == ""){
                        cell.message_label.text = "  "
                    }
                }
                
            }else{
                
                if message.only_emojies == false{
                    cell.view.backgroundColor = Colors.white
                    cell.message_label.textColor = Colors.black
                }
                
                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                
                cell.message_label.textAlignment = .left
                
                if ((cell.message_label.text?.widthWithConstrained(cell.message_label.frame.height, font: cell.message_label.font))! <= self.view.frame.width - (2 * 36)){
                    cell.rightConstraint.isActive = false
                    
                    if (cell.message_label.text == ""){
                        cell.message_label.text = "  "
                    }
                }
            }
            
            // Animate
            if cell.message_label.text!.contains("Lucie <3") || cell.message_label.text!.contains((master.conversations[indexOfUser].firstname)! + " <3") || cell.message_label.text!.contains((master.firstname)! + " <3"){
                animateBubbleWithRainbowColors(times: 7, cell: cell)
            }
            
            cell.alpha = 0
            
            
            
            return cell
            
        case is ImageMessage:
            
            let cell = Bundle.main.loadNibNamed("ImageMessageCell", owner: self, options: nil)?.first as! ImageMessageCell
            
            let message = master.conversations[indexOfUser].conversation[indexPath.row] as! ImageMessage
            
            //cell.message_imageView.download(from: message.link!)
            cell.message_imageView.image = message.image
            cell.message_imageView.contentMode = .scaleAspectFill
            cell.message_imageView.clipsToBounds = true
            cell.message_imageView.layer.cornerRadius = 23
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            if  message.is_sender == true {
                
                cell.message_imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
                
                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
                
            }else{
                cell.message_imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                
                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            }
            
            return cell
            
        case is LocationMessage:
            let cell = Bundle.main.loadNibNamed("LocationMessageCell", owner: self, options: nil)?.first as! LocationMessageCell
            
            let message = master.conversations[indexOfUser].conversation[indexPath.row] as! LocationMessage
            
            let latitude: CLLocationDegrees = (message.coordinate?.latitude)!
            let longitude: CLLocationDegrees = (message.coordinate?.longitude)!
            
            let latDelta:CLLocationDegrees = 0.01
            let lonDelta:CLLocationDegrees = 0.01
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            let region = MKCoordinateRegion(center: location, span: span)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = message.coordinate!
            
            if message.is_sender! {
                annotation.title = master.fullname
            }else{
                annotation.title = master.conversations[indexOfUser].fullname
            }
            
            cell.map.addAnnotation(annotation)
            cell.map.setRegion(region, animated: false)
            cell.map.setCenter(message.coordinate!, animated: true)
            
            cell.map.layer.cornerRadius = 23
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            if  message.is_sender == true {
                
                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
                cell.map.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            }else{
                
                cell.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                cell.map.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
            }
            
            return cell
            
        case is FirstInformationMessage:
            fallthrough
        case is InformationMessage:
            
            let cell = Bundle.main.loadNibNamed("InformationMessageCell", owner: self, options: nil)?.first as! InformationMessageCell
            
            let message = master.conversations[indexOfUser].conversation[indexPath.row] as! InformationMessage
            
            cell.information.text = message.text
            
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
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                var message = master.conversations[indexOfUser].conversation[indexPath.row]
                
                switch master.conversations[indexOfUser].conversation[indexPath.row]{
                case is TextMessage:
                    
                    message = message as! TextMessage
                    
                let alertController = UIAlertController(title: nil,
                                                            message: nil,
                                                            preferredStyle: .actionSheet)
                    
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let copy = UIAlertAction(title: "Copy", style: .default) { (action) in
                    
                    UIPasteboard.general.string = (message as! TextMessage).text?.string
                    
                }
                let speak = UIAlertAction(title: "Speak", style: .default) { (action) in
                    
                    // Line 1. Create an instance of AVSpeechSynthesizer.
                    let speechSynthesizer = AVSpeechSynthesizer()
                    // Line 2. Create an instance of AVSpeechUtterance and pass in a String to be spoken.
                    let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: ((message as! TextMessage).text?.string)!)
                    //Line 3. Specify the speech utterance rate. 1 = speaking extremely the higher the values the slower speech patterns. The default rate, AVSpeechUtteranceDefaultSpeechRate is 0.5
                    //speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 4.0
                    // Line 4. Specify the voice. It is explicitly set to English here, but it will use the device default if not specified.
                    
                    if let language = NSLinguisticTagger.dominantLanguage(for: (message as! TextMessage).text!.string) {
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
                    print("Not implemented yet")
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch master.conversations[indexOfUser].conversation[indexPath.row]{
        case is ImageMessage:
            if (self.view.frame.width < self.view.frame.height){
                return self.view.frame.width
            }
            
            return self.view.frame.height
            
        case is LocationMessage:
            
            if (self.view.frame.width < self.view.frame.height){
                return self.view.frame.width
            }
            
            return self.view.frame.height
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Direct to maps if the message is a location
        if master.conversations[indexOfUser].conversation[indexPath.row] is LocationMessage {
            
            let message = master.conversations[indexOfUser].conversation[indexPath.row] as! LocationMessage
            
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (message.coordinate?.latitude)!, longitude: (message.coordinate?.longitude)!))
            
            let source = MKMapItem(placemark: placemark)
            
            if message.is_sender! {
                source.name = NSLocalizedString("You", comment: "The pronoun")
            }else{
                source.name = master.conversations[indexOfUser].fullname
            }
            
            MKMapItem.openMaps(with: [source], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
            
        }
        
        if master.conversations[indexOfUser].conversation[indexPath.row] is ImageMessage {
            
//            let secondViewController: ImagePreviewFullViewCell = ImagePreviewFullViewCell()
//
//            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    
    
}

// MARK: Send message

extension ChatVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        deleteFirstMessage()
        
        // Did the master use the word "fuck"? If yes let's replace it with something more appropriate -> "🦆"
        textField.text = textField.text?.replacingOccurrences(of: "fuck", with: "🦆", options: .caseInsensitive, range: nil)
        
        master.conversations[indexOfUser].conversation.append(TextMessage(text: textField.attributedText as! NSMutableAttributedString, is_sender: true))
        
        // MARK: TODO - Send message
        
        textField.text = ""
        
        updateTableView(animated: true)
        
        return true
    }
}

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func getImageFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.photoLibrary
            image.mediaTypes = [/*"public.movie",*/ "public.image"]
            image.allowsEditing = true
            self.present(image, animated: true, completion: nil)
        }
    }
    
    func getImageFromCamera(){
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
        let image = info[UIImagePickerController.InfoKey.editedImage]
        
        // Display sent image in chat
        let message = ImageMessage(image: image as! UIImage, is_sender: true)
        master.conversations[indexOfUser].conversation.append(message)
        
        updateTableView(animated: true)
        
        picker.dismiss(animated: true, completion: nil)
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
        master.coordinate = manager.location!.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
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
