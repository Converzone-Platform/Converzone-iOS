//
//  Internet.swift
//  converzone
//
//  Created by Goga Barabadze on 03.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import SystemConfiguration
import UIKit
import Network
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MapKit

public class Internet: NSObject {
    
    static var update_chat_tableview_delegate: ChatUpdateDelegate?
    static var update_conversations_tableview_delegate: ConversationUpdateDelegate?
    static var database_reference = Database.database().reference()
    static var storage_reference = Storage.storage().reference()
    
    /// Set up value listeners for Database
    class func setUpListeners(){
        
        self.listenForNewConversations()
        
    }
    
    // MARK: - Connectivity
    
    
    /// Return if we have an internet connection. No differenciation with Cellular or Wifi. They are treated the same way
    class func isOnline() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    // MARK: Phone verification
    
    /// Requests a silent push notification to the device and afterwards it send a SMS to the phone number
    /// - Parameter phoneNumber: The phone number to which the SMS is sent
    static func verify(phoneNumber: String){
    
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            
          if error != nil {
            return
          }
            
          UserDefaults.standard.setValue(verificationID, forKey: "verificationID")
        }
        
    }
    
    
    /// Sign in our user
    /// - Parameter verificationID: The verification ID obtained from invoking verifyPhoneNumber:completion:
    /// - Parameter verificationCode: The verification code obtained from the user.
    /// - Parameter closure: Get back a bool which says if our sign in was successful
    static func signIn(with verificationCode: String, closure: @escaping (Bool) -> Void) {
        
        guard let verificationID = UserDefaults.standard.string(forKey: "verificationID") else{
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
          if error != nil {
            
            closure(false)
          }
          
            closure(true)
            
            master.uid = Auth.auth().currentUser?.uid
        }
        
    }
    
    // MARK: Download and cache image
    
    /// Cache all images in the app
    static let imageCache = NSCache<NSString, UIImage>()
    
    
    /// Download any image from any url
    /// - Parameter url: The url from where to download the image
    /// - Parameter completion: Asynchronously give back the image we retrieved
    private static func downloadImage(withURL url: URL, completion: @escaping (_ image:UIImage?)->()) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            var downloadedImage:UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            
            if downloadedImage != nil {
                imageCache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
            
        }
        
        dataTask.resume()
    }
    
    /// Check if we need to download the image from the url or if we have it cached
    /// - Parameter url: The url from where to download the image
    /// - Parameter completion: Asynchronously give back the image we retrieved
    static func getImage(withURL url: String, completion: @escaping (_ image:UIImage?)->()) {
        if let image = imageCache.object(forKey: url as NSString) {
            completion(image)
        } else {
            downloadImage(withURL: URL(string: url)!, completion: completion)
        }
    }
    
    // MARK: - Sending messages
    
    /// Decides what type of message it is and redirects to it's specific function to further handling
    /// - Parameter message: The message to send
    /// - Parameter receiver: The user who will receive the message
    static func send(message: Message, receiver: User){
        
        switch message {
        case is TextMessage: send(message: message as! TextMessage, receiver: receiver)
        case is InformationMessage: send(message: message as! InformationMessage, receiver: receiver)
        default: print("Message type is not supported yet")
        }
        
    }
    
    /// Send the TextMessage to the database. Firebase Functions will send it to the right user automatically
    /// - Parameter message: The TextMessage to send
    /// - Parameter receiver: The user who will receive the message
    private static func send(message: TextMessage, receiver: User){
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid!, second: receiver.uid!)).child("messages").child(String(message.hashValue)).setValue(["sender": master.uid!, "receiver": receiver.uid!, "date": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: message.date!), "text": message.text!, "type": "TextMessage"])
        
    }
    
    /// Send the InformationMessage to the database. Firebase Functions will send it to the right user automatically
    /// - Parameter message: The InformationMessage to send
    /// - Parameter receiver: The user who will receive the message
    private static func send(message: InformationMessage, receiver: User){
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid!, second: receiver.uid!)).child("messages").child(String(message.hashValue)).setValue(["sender": master.uid!, "receiver": receiver.uid!, "date": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: message.date!), "text": message.text!, "type": "InformationMessage"])
        
    }
    
    /// Generate one single conversation id out of two user ids
    /// - Parameter first: user id A
    /// - Parameter second: user id B
    private static func generateConversationID(first: String, second: String) -> String{
        
        if first > second {
            
            return first + second
            
        }
        
        return second + first
        
    }
    
    // MARK: Receiving messages
    
    /// Listener for new conversations. Once it receivers a new conversation it sets a listener for messages in the new conversation
    private static func listenForNewConversations(){

        self.database_reference.child("users").child(master.uid!).child("conversations").observe(.childAdded) { (snapshot) in

            let conversationid = snapshot.value as! String
            //let partnerid = snapshot.key
            
            // MARK: TODO - Save new user and get their data
            
            // Add a listener to the conversation
            listenForNewMessageAt(conversationID: conversationid)
            
        }

    }
    
    /// Listen for messages in the conversation
    private static func listenForNewMessageAt(conversationID: String){
        
        self.database_reference.child("conversations").child(conversationID).child("messages").queryOrdered(byChild: "date").queryLimited(toLast: 10).observe(.childAdded) { (snapshot) in
            
            let message = snapshot.value as! NSDictionary
            
            receive(message: message)
            
        }
        
    }
    
    
    /// Decides what type of message it is and redirects to it's specific function to further handling
    /// - Parameter message: The received message
    private static func receive(message: NSDictionary){
        
        let type = message["type"] as! String
        
        switch(type){
        case "TextMessage": receive(textMessage: message)
        case "InformationMessage": receive(informationMessage: message)
        default: print("Message type is not supported yet")
        }
        
    }
    
    /// Handles the receiving of a InformationMessages
    /// - Parameter textMessage: The received InformationMessage
    private static func receive(informationMessage: NSDictionary){
        
        let sender = informationMessage["sender"] as! String
        let is_sender = sender == master.uid!
        
        // MARK: TODO - If I am the sender and I receive the message back we can say that it works as a sent indicator for messages
        if is_sender{
            return
        }
        
        let text = informationMessage["text"] as! String
        let receiver = informationMessage["receiver"] as! String
        
        let date_string = informationMessage["date"] as! String
        let date = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: date_string)
        
        let message = InformationMessage()
        message.text = text
        message.is_sender = is_sender
        message.date = date
        
        findConversationAndAddMessage(message: message, uid: receiver)
        findConversationAndAddMessage(message: message, uid: sender)
        
    }
    
    /// Handles the receiving of a TextMessage
    /// - Parameter textMessage: The received TextMessage
    private static func receive(textMessage: NSDictionary){
        
        let sender = textMessage["sender"] as! String
        let is_sender = sender == master.uid!
        
        // MARK: TODO - If I am the sender and I receive the message back we can say that it works as a sent indicator for messages
        if is_sender{
            return
        }
        
        let text = textMessage["text"] as! String
        let receiver = textMessage["receiver"] as! String
        
        let date_string = textMessage["date"] as! String
        let date = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: date_string)
        
        let message = TextMessage()
        message.text = text
        message.is_sender = is_sender
        message.date = date
        
        findConversationAndAddMessage(message: message, uid: receiver)
        findConversationAndAddMessage(message: message, uid: sender)
        
    }
    
    /// Find the conversation with the correct partner id and add the message
    private static func findConversationAndAddMessage(message: Message, uid: String){
        
        // Iterate through the conversations and find the right person
        for user in master.conversations {
            
            if user.uid == uid {
                
                user.conversation.append(message)
                
                self.update_chat_tableview_delegate?.didUpdate(sender: Internet())
                
            }
            
        }
        
    }
    
    // MARK: Push Notifications
    
    /// Update the Push Notification token to Firebase
    /// - Parameter token: The token to update
    static func upload(token: String){
        
        guard let uid = master.uid else{
            return
        }
        
        self.database_reference.child("users").child(uid).updateChildValues(["token": token])
        
    }
    
    // MARK: Master update
    
    /// Packs all the data from the master and sends it to the database
    static func upload(){
        
        self.database_reference.child("users").child(master.uid!).updateChildValues(master.toDictionary())
        
    }
    
    /// Update the country on the database
    /// - Parameter country: The country to chango to
    static func upload(country: Country){
        
        self.database_reference.child("users").child(master.uid!).updateChildValues(["country" : country.name!])
        
    }
    
    /// Get the newest version of the master from the database
    static func getMaster(){
        
        self.database_reference.child("users").child(master.uid!).observeSingleEvent(of: .value) { (snapshot) in
            
            let values = snapshot.value as! NSDictionary
            
            transformIntoMasterObject(dictionary: values)
            
        }
        
    }
    
    /// Upload profile image to database
    /// - Parameter image: The image to upload
    static func upload(image: UIImage){
        
        let jpeg = image.jpegData(compressionQuality: 1.0)
        
        storage_reference.child("profile_images").child(master.uid! + ".jpg").putData(jpeg!, metadata: nil) { (metadata, error) in
            
            if error != nil {
                
                alert("Image upload went wrong", error!.localizedDescription)
                
            }
            
            self.storage_reference.child("/profile_images/" + master.uid! + ".jpg").downloadURL { (url, error) in
                
                if error != nil {
                    print(error?.localizedDescription)
                }
                
                master.link_to_profile_image = url!.absoluteString
                
            }
            
        }
    }
    
    /// Transforms the dictionary to master
    private static func transformIntoMasterObject (dictionary: NSDictionary) {
        
        master.firstname = dictionary["firstname"] as? String
        master.lastname = dictionary["lastname"] as? String
        master.gender = Gender.toGender(gender: dictionary["gender"] as! String)
        master.birthdate = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: dictionary["birthdate"] as! String)
        master.country = Country(name: dictionary["country"] as! String)
        master.link_to_profile_image = dictionary["link_to_profile_image"] as! String
        master.device_token = dictionary["device_token"] as! String
        master.discoverable = dictionary["discoverable"] as! Bool
        master.interface_language = Language(name: dictionary["interface_language"] as! String)
        master.interests = NSAttributedString(string: dictionary["interests"] as! String)
        master.status = NSAttributedString(string: dictionary["status"] as! String)
        
    }
    
    // MARK: Languages
    
    /// Upload Languages of the master to the database
    static func uploadLanguages(){
        
        Internet.removeLanguages()
        
        self.database_reference.child("users").child(master.uid!).child("speak_languages").setValue(master.speakLanguagesToDictionary())
        
        if master.learn_languages.count == 0 { return }
        
        self.database_reference.child("users").child(master.uid!).child("learn_languages").setValue(master.learnLanguagesToDictionrary())
    }
    
    /// Remove all languages of the master in the database
    private static func removeLanguages(){
        
        self.database_reference.child("users").child(master.uid!).child("speak_languages").removeValue()
        self.database_reference.child("users").child(master.uid!).child("learn_languages").removeValue()
        
    }
    
    /// Get languages for the uis
    /// - Parameter uid: Id from the user we want the languages for
    /// - Parameter progress: "speak_languages" or "learn_languages"
    /// - Parameter closure: Give back the languages array once the asynchronous task is finished
    static func getLanguagesFor(uid: String, progress: String, closure: @escaping ([Language]?) -> Void){
        
        self.database_reference.child("users").child(uid).child(progress).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let language_array = snapshot.value as? [String] else {
                closure(nil)
                return
            }
            
            var languages: [Language] = []
            
            for language in language_array {
                languages.append(Language(name: language))
            }
            
            closure(languages)
        }
        
    }
    
    // MARK: Blocking and reporting users
    
    /// Report a person
    /// - Parameter userid: The  uid of the person to be reported
    /// - Parameter reason: Reson of report
    static func report(userid: String, reason: String){
        
        self.database_reference.child("users").child(master.uid!).child("reportee").child(userid).setValue(["reason" : reason])
        
    }
    
    /// Block an user
    /// - Parameter userid: User's uid to be blocked
    static func block(userid: String){
        
        master.blocked_users.insert(userid)
        
        self.database_reference.child("users").child(master.uid!).child("blockee").setValue(Array(master.blocked_users))
        
    }
    
    /// Unblock an user
    /// - Parameter userid: User's uid to be unblocked
    static func unblock(userid: String){
        
        master.blocked_users.remove(userid)
        
        self.database_reference.child("users").child(master.uid!).child("blockee").setValue(Array(master.blocked_users))
    }
}
