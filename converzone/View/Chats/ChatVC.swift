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
import SocketIO

var indexOfUser: Int = 0

class ChatVC: UIViewController, UpdateDelegate {
    
    @IBOutlet weak var messageInputBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputMessage: UIView!
    @IBOutlet weak var message_textField: UITextField!
    
    // To update the table view from the Internet class
    let updates = Internet()
    
    //Location purposes
    let locationManager = CLLocationManager()
    
    @IBAction func audio_button(_ sender: Any) {
        print("Send audio message")
    }
    
    @IBAction func more_button(_ sender: Any) {
        
        let alert = UIAlertController()
        
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            
            self.getImageFromCamera()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Photo or Video", style: .default , handler:{ (UIAlertAction)in
            
            self.getImageFromLibrary()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Contact", style: .default , handler:{ (UIAlertAction)in
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Location", style: .default , handler:{ (UIAlertAction)in
            
            self.setUpLocationServices()
            
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    let locationMessage = LocationMessage()
                    locationMessage.is_sender = true
                    
                    self.locationManager.requestLocation()
                    locationMessage.coordinate = master?.coordinate
                    locationMessage.date = Date()
                    
                    master?.conversations[indexOfUser].conversation.append(locationMessage)
                    
                    self.updateTableView(animated: true)
                    
                }
            } else {
                print("Location services are not enabled")
            }
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        self.present(alert, animated: true, completion: {
            
        })
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        setUpTableView()
        setUpMessageTextField()
        setUpObervers()
        
        message_textField.delegate = self
        
        setUpInfoButton()
        
        navigationItem.titleView = navTitleWithImageAndText(titleText: master!.conversations[indexOfUser].fullname!, imageLink: master!.conversations[indexOfUser].link_to_profile_image!)
        
        updates.delegate = self
    }
    
    func didUpdate(sender: Internet) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        }
    }
    
    func changeBackBarButton(title: String){
        let backButton = UIBarButtonItem()
        backButton.title = title
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpLocationServices()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        scrollToBottom(animated: false)
        
        changeBackBarButton(title: "")
    }
    
    @objc func goToConversations(){
        //Go to next view controller
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let conversations = storyBoard.instantiateViewController(withIdentifier: "ConversationsVC")
        self.navigationController?.pushViewController(conversations, animated: true)
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
        
        master!.conversations[indexOfUser].getImage(with: imageLink, completion: { (image) in
            imageView.image = image
        })
        
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
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showMoreOfPartner))
        navigationItem.titleView?.addGestureRecognizer(gesture)
        
        titleView.addGestureRecognizer(gesture)
        
        return titleView
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setUpInfoButton(){
        let infoButton = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(handleInfoButton))
        navigationItem.rightBarButtonItem = infoButton
    }
    
    @objc func handleInfoButton(){
        //Go to next view controller
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let chatSettingsVC = storyBoard.instantiateViewController(withIdentifier: "ChatSettingsVC")
        self.navigationController?.pushViewController(chatSettingsVC, animated: true)
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
    
    
    
    @objc func showMoreOfPartner(){

        print("Show profile")
        
    }
    
    func setUpMessageTextField(){
        let amountOfLinesToBeShown: CGFloat = 6
        let maxHeight: CGFloat = message_textField.font!.lineHeight * amountOfLinesToBeShown
        message_textField.sizeThatFits(CGSize(width: message_textField.frame.size.width, height: maxHeight))
    }
    
    @objc func handleKeyboard(_ notification: Notification){
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if notification.name == UIResponder.keyboardWillShowNotification{
            self.messageInputBottomConstraint.constant = keyboardFrame.size.height
        }else{
            self.messageInputBottomConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        scrollToBottom(animated: true)
    }
    
    func updateTableView(animated: Bool){
        
        let indexPath = NSIndexPath(row: tableView.numberOfRows(inSection: 0), section: 0) as IndexPath
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        
        scrollToBottom(animated: true)
    }
    
    func scrollToBottom(animated: Bool){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: ((master?.conversations[indexOfUser].conversation.count)!)-1, section: 0)
            
            if (master?.conversations[indexOfUser].conversation.count != 0){
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
            
        }
    }
    
    @objc func didTakeScreenshot(){
        
        let screenshot_message = InformationMessage()
        
        screenshot_message.text = NSLocalizedString("You", comment: "The pronoun") + " " + NSLocalizedString("took a screenshot!", comment: "Message when the master or the partner takes a screenshot")
        screenshot_message.date = NSDate() as Date
        
        master?.conversations[indexOfUser].conversation.append(screenshot_message)
        
        //MARK: TODO - Send this to the partner
        
        updateTableView(animated: true)
        
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (master?.conversations[indexOfUser].conversation.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch master?.conversations[indexOfUser].conversation[indexPath.row]{
            
        case is TextMessage:
            
            let cell = Bundle.main.loadNibNamed("TextMessageCell", owner: self, options: nil)?.first as! TextMessageCell
            
            let message = master?.conversations[indexOfUser].conversation[indexPath.row] as! TextMessage
            
            cell.message_label.text = message.text!
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
                
                if message.text!.count <= 5{
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
            
            // Check if the message contains a link
//            let attributedString = NSMutableAttributedString(string: "Want to learn iOS? You should visit the best source of free iOS tutorials!")
//            attributedString.addAttribute(.link, value: "https://www.hackingwithswift.com", range: NSRange(location: 19, length: 55))
//
//            textView.attributedText = attributedString
            
            return cell
            
        case is ImageMessage:
            
            let cell = Bundle.main.loadNibNamed("ImageMessageCell", owner: self, options: nil)?.first as! ImageMessageCell
            
            let message = master?.conversations[indexOfUser].conversation[indexPath.row] as! ImageMessage
            
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
            
            let message = master?.conversations[indexOfUser].conversation[indexPath.row] as! LocationMessage
            
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
                annotation.title = NSLocalizedString("You", comment: "The pronoun")
            }else{
                annotation.title = master?.conversations[indexOfUser].fullname
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
            
        case is InformationMessage:
            
            let cell = Bundle.main.loadNibNamed("InformationMessageCell", owner: self, options: nil)?.first as! InformationMessageCell
            
            let message = master?.conversations[indexOfUser].conversation[indexPath.row] as! InformationMessage
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch master?.conversations[indexOfUser].conversation[indexPath.row]{
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
        if master?.conversations[indexOfUser].conversation[indexPath.row] is LocationMessage {
            
            let message = master?.conversations[indexOfUser].conversation[indexPath.row] as! LocationMessage
            
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (message.coordinate?.latitude)!, longitude: (message.coordinate?.longitude)!))
            
            let source = MKMapItem(placemark: placemark)
            
            if message.is_sender! {
                source.name = NSLocalizedString("You", comment: "The pronoun")
            }else{
                source.name = master?.conversations[indexOfUser].fullname
            }
            
            MKMapItem.openMaps(with: [source], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
            
        }
        
        if master?.conversations[indexOfUser].conversation[indexPath.row] is ImageMessage {
            
//            let secondViewController: ImagePreviewFullViewCell = ImagePreviewFullViewCell()
//
//            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
}

// MARK: Send message

extension ChatVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        master?.conversations[indexOfUser].conversation.append(TextMessage(text: textField.text!, is_sender: true))
        
        Internet.sendText(message: textField.text!, to: (master?.conversations[indexOfUser].uid)!)
        
        updateTableView(animated: true)
        
        textField.text = ""
        
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
        master?.conversations[indexOfUser].conversation.append(message)
        
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
        master!.coordinate = manager.location!.coordinate
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
protocol UpdateDelegate {
    func didUpdate(sender: Internet)
}
