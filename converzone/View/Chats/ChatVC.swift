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

class ChatVC: UIViewController {
    
    @IBOutlet weak var messageInputBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputMessage: UIView!
    @IBOutlet weak var message_textField: UITextField!
    
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
                    
                    self.messages.append(locationMessage)
                    
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
    
    var messages: [Message] = []{
        
        didSet{
            
        }
        
    }
    
    override func viewDidLoad() {
       
        self.navigationItem.title = "MC Haselnussbaum"
        
//        let profile_pic = UIImageView(image: UIImage(named: "1"))
//        profile_pic.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
//
//        self.navigationItem.titleView = profile_pic
//        self.navigationItem.titleView?.contentMode = .scaleAspectFit
//
//        profile_pic.layer.masksToBounds = false
//        profile_pic.layer.cornerRadius = profile_pic.frame.width / 2
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 1000
        
        tableView.backgroundColor = Colors.backgroundGrey
        
        createFakeMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didTakeScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willShowKeyboard),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        message_textField.delegate = self
        
        setUpMessageTextField()
        
    }
    
    func setUpMessageTextField(){
        let amountOfLinesToBeShown: CGFloat = 6
        let maxHeight: CGFloat = message_textField.font!.lineHeight * amountOfLinesToBeShown
        message_textField.sizeThatFits(CGSize(width: message_textField.frame.size.width, height: maxHeight))
    }
    
    override func viewWillLayoutSubviews() {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        scrollToBottom(animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func willShowKeyboard(_ notification: Notification){
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            UIView.animate(withDuration: 1.5) {
                self.messageInputBottomConstraint.constant = keyboardHeight
            }
            
        }
        
    }
    
    func updateTableView(animated: Bool){
        
        let indexPath = NSIndexPath(row: tableView.numberOfRows(inSection: 0), section: 0) as IndexPath
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        
        scrollToBottom(animated: true)
    }
    
    func scrollToBottom(animated: Bool){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    func createFakeMessages(){
        
        for _ in 0...2000{
            messages.append(TextMessage(text: randomString(), is_sender: arc4random() % 2 == 0))
        }
        
        //messages.append(TextMessage(text:"", is_sender: true))
    }
    
    
    
    func randomString() -> String {
        let randomMessages = ["14  For if you forgive other people when they sin against you, your heavenly Father will also forgive you. 15  But if you do not forgive others their sins, your Father will not forgive your sins.", "12  “Even now,” declares the LORD, “return to me with all your heart, with fasting and weeping and mourning.” 13  Rend your heart and not your garments. Return to the LORD your God, for he is gracious and compassionate, slow to anger and abounding in love, and he relents from sending calamity.", "1  “Come, let us return to the LORD. He has torn us to pieces but he will heal us; he has injured us but he will bind up our wounds. 2  After two days he will revive us; on the third day he will restore us, that we may live in his presence.", "4  One thing I ask from the LORD, this only do I seek: that I may dwell in the house of the LORD all the days of my life, to gaze on the beauty of the LORD and to seek him in his temple.", "8  Keep my decrees and follow them. I am the LORD, who makes you holy.", "15  So then, brothers and sisters, stand firm and hold fast to the teachings we passed on to you, whether by word of mouth or by letter.", "14  For if you forgive other people when they sin against you, your heavenly Father will also forgive you. 15  But if you do not forgive others their sins, your Father will not forgive your sins.", "刃」在一把有柄刀的刀刃地方加一點，指出這裏是刀口最鋒利的地方", "迎刃而解」：迎著刀刃的竹子，會順著刀勢裂開。比喻戰事進展順利。語出《晉書．杜預列傳》。後形容相連的事物很容易分解，亦用來比喻事情很容易處理。"]
        return randomMessages[Int(arc4random_uniform(UInt32(randomMessages.count)))]
    }
    
    @objc func didTakeScreenshot(){
        
        let screenshot_message = InformationMessage()
        
        screenshot_message.text = NSLocalizedString("You", comment: "The pronoun") + " " + NSLocalizedString("took a screenshot!", comment: "Message when the master or the partner takes a screenshot")
        screenshot_message.date = NSDate() as Date
        
        messages.append(screenshot_message)
        
        //MARK: TODO - Send this to the partner
        
        updateTableView(animated: true)
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch messages[indexPath.row]{
            
        case is TextMessage:
            
            let cell = Bundle.main.loadNibNamed("TextMessageCell", owner: self, options: nil)?.first as! TextMessageCell
            
            let message = messages[indexPath.row] as! TextMessage
            
            cell.message_label.text = message.text!
            
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
            
            
            return cell
            
        case is ImageMessage:
            
            let cell = Bundle.main.loadNibNamed("ImageMessageCell", owner: self, options: nil)?.first as! ImageMessageCell
            
            let message = messages[indexPath.row] as! ImageMessage
            
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
            
            let message = messages[indexPath.row] as! LocationMessage
            
            let latitude:CLLocationDegrees = (message.coordinate?.latitude)!
            let longitude:CLLocationDegrees = (message.coordinate?.longitude)!
            let latDelta:CLLocationDegrees = 1
            let lonDelta:CLLocationDegrees = 1
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            let region = MKCoordinateRegion(center: location, span: span)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = message.coordinate!
            //MARK: TODO - Implement this
            //annotation.text = ""
            
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
            
            let message = messages[indexPath.row] as! InformationMessage
            
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
        
        switch messages[indexPath.row]{
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
}

extension ChatVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messages.append(TextMessage(text: textField.text!, is_sender: arc4random() % 2 == 0))
        
        
        
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
            image.mediaTypes = ["public.movie", "public.image"]
            image.allowsEditing = true
            self.present(image, animated: true, completion: nil)
        }
    }
    
    func getImageFromCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.camera
            image.mediaTypes = ["public.movie", "public.image"]
            image.allowsEditing = true
            image.cameraCaptureMode = .photo
            self.present(image, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage]
        
        // Display sent image in chat
        let message = ImageMessage(image: image as! UIImage, is_sender: true)
        messages.append(message)
        
        updateTableView(animated: true)
        
        Internet.sendImage(message: image as! UIImage)
        
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
