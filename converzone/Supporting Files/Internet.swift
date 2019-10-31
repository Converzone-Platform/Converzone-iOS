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
    static var update_discovery_tableview_delegate: DiscoverUpdateDelegate?
    
    static var database_reference = Database.database().reference()
    static var storage_reference = Storage.storage().reference()
    
    static var all_time_user_count = 4
    static var user_count = 4
    
    /// Set up value listeners for Database
    class func setUpListeners(){
        
        self.listenForNewConversations()
        self.listenForDidChangeAuthState()
        self.listenForAllTimeUserCountChange()
        self.listenForUserCount()
        
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
        
        guard let verificationID = UserDefaults.standard.string(forKey: "verificationID") else {
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
          if error != nil {
            
            closure(false)
            
            return
          }
          
            closure(true)
            
            master.uid = Auth.auth().currentUser!.uid
            
            // Delete Verification Code
            UserDefaults.standard.removeObject(forKey: "verificationID")
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
        
        guard let url_object = URL(string: url) else{
            return
        }
        
        if let image = imageCache.object(forKey: url as NSString) {
            completion(image)
        } else {
            downloadImage(withURL: url_object, completion: completion)
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
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: receiver.uid)).child("messages").child(String(message.hashValue)).setValue(["sender": master.uid, "receiver": receiver.uid, "date": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: message.date!), "text": message.text!, "type": "TextMessage"])
        
    }
    
    /// Send the InformationMessage to the database. Firebase Functions will send it to the right user automatically
    /// - Parameter message: The InformationMessage to send
    /// - Parameter receiver: The user who will receive the message
    private static func send(message: InformationMessage, receiver: User){
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: receiver.uid)).child("messages").child(String(message.hashValue)).setValue(["sender": master.uid, "receiver": receiver.uid, "date": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: message.date!), "text": message.text!, "type": "InformationMessage"])
        
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
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).child("conversations").observe(.childAdded) { (snapshot) in

            let conversationid = snapshot.value as! String
            
            Internet.getUser(with: snapshot.key) { (user) in
                
                master.conversations.append(user!)
                
                self.update_conversations_tableview_delegate?.didUpdate(sender: Internet())
                
                // Add a listener to the conversation
                listenForNewMessageAt(conversationID: conversationid)
            }
        }

    }
    
    /// Listen for messages in the conversation
    private static func listenForNewMessageAt(conversationID: String){
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("conversations").child(conversationID).child("messages").queryOrdered(byChild: "date").queryLimited(toLast: 10).observe(.childAdded) { (snapshot) in
            
            let message = snapshot.value as! NSDictionary
            
            receive(message: message)
            
            self.update_conversations_tableview_delegate?.didUpdate(sender: Internet())
            
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
        let is_sender = sender == master.uid
        
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
        let is_sender = sender == master.uid
        
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
                
//                if user.conversation.last == nil || user.conversation.last!.hashValue != message.hashValue {
//
//                }
                
                user.conversation.append(message)
                
                self.update_chat_tableview_delegate?.didUpdate(sender: Internet())
            }
            
        }
        
    }
    
    // MARK: Push Notifications
    
    /// Update the Push Notification token to Firebase
    /// - Parameter token: The token to update
    static func upload(token: String){
        
        if master.uid == ""{
            return
        }
        
        self.database_reference.child("users").child(master.uid).updateChildValues(["device_token": token])
        
    }
    
    // MARK: Master update
    
    /// Packs all the data from the master and sends it to the database
    static func upload(){
        
        self.database_reference.child("users").child(master.uid).updateChildValues(master.toDictionary())
        
    }
    
    /// Update the country on the database
    /// - Parameter country: The country to chango to
    static func upload(country: Country){
        
        self.database_reference.child("users").child(master.uid).updateChildValues(["country" : country.name!])
        
    }
    
    /// Get the newest version of the master from the database
    static func getMaster(){
        
        if master.uid == ""{
            return
        }
        
        self.database_reference.child("users").child(master.uid).observeSingleEvent(of: .value) { (snapshot) in
            
            let values = snapshot.value as! NSDictionary
            
            transformIntoMasterObject(dictionary: values)
            
        }
        
    }
    
    /// User was logged out (or logged in)
    private static func listenForDidChangeAuthState(){
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if user == nil {
                
                Internet.signOut()
                Navigation.change(navigationController: "SplashScreenVC")
                
            }
            
        }
        
    }
    
    static func signOut(){
        do{
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "DidFinishRegistration")
        }catch{
            alert("Signing out ...", "An unknown error occurred")
        }
    }
    
    /// Upload profile image to database
    /// - Parameter image: The image to upload
    static func upload(image: UIImage){
        
        let jpeg = image.jpegData(compressionQuality: 1.0)
        
        storage_reference.child("profile_images").child(master.uid + ".jpg").putData(jpeg!, metadata: nil) { (metadata, error) in
            
            if error != nil {
                
                alert("Image upload went wrong", error!.localizedDescription)
                return
            }
            
            self.storage_reference.child("/profile_images/" + master.uid + ".jpg").downloadURL { (url, error) in
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                
                master.link_to_profile_image = url!.absoluteString
                
                Internet.upload(linkToProfileImage: master.link_to_profile_image)
            }
        }
    }
    
    /// Upload link to profile image to Firebase Database
    /// - Parameter linkToProfileImage: Link to be uploaded
    private static func upload(linkToProfileImage: String){
        self.database_reference.child("users").child(master.uid).updateChildValues(["link_to_profile_image": linkToProfileImage])
    }
    
    /// Transforms the dictionary to master
    private static func transformIntoMasterObject (dictionary: NSDictionary) {
        
        master.firstname = dictionary["firstname"] as! String
        master.lastname = dictionary["lastname"] as! String
        master.gender = Gender.toGender(gender: dictionary["gender"] as! String)
        master.birthdate = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: dictionary["birthdate"] as! String)
        master.country = Country(name: dictionary["country"] as! String)
        master.link_to_profile_image = dictionary["link_to_profile_image"] as! String
       
        master.discoverable = dictionary["discoverable"] as! Bool
        master.interests = NSAttributedString(string: dictionary["interests"] as! String)
        master.status = NSAttributedString(string: dictionary["status"] as! String)
        
    }
    
    // MARK: Languages
    
    /// Upload Languages of the master to the database
    static func uploadLanguages(){
        
        Internet.removeLanguages()
        
        self.database_reference.child("users").child(master.uid).child("speak_languages").setValue(master.speakLanguagesToDictionary())
        
        if master.learn_languages.count == 0 { return }
        
        self.database_reference.child("users").child(master.uid).child("learn_languages").setValue(master.learnLanguagesToDictionrary())
    }
    
    /// Remove all languages of the master in the database
    private static func removeLanguages(){
        
        self.database_reference.child("users").child(master.uid).child("speak_languages").removeValue()
        self.database_reference.child("users").child(master.uid).child("learn_languages").removeValue()
        
    }
    
    /// Get languages for the uis
    /// - Parameter uid: Id from the user we want the languages for
    /// - Parameter progress: "speak_languages"  or "learn_languages"
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
        
        self.database_reference.child("users").child(master.uid).child("reportee").child(userid).setValue(["reason" : reason])
        
    }
    
    /// Block an user locally and on the database
    /// - Parameter userid: User's uid to be blocked
    static func block(userid: String){
        
        master.blocked_users.insert(userid)
        
        self.database_reference.child("users").child(master.uid).child("blockee").setValue(Array(master.blocked_users))
        
    }
    
    /// Unblock an user locally and on the database
    /// - Parameter userid: User's uid to be unblocked
    static func unblock(userid: String){
        
        master.blocked_users.remove(userid)
        
        self.database_reference.child("users").child(master.uid).child("blockee").setValue(Array(master.blocked_users))
    }
    
    // MARK: Discovery
    
    private static func listenForAllTimeUserCountChange(){
        
        self.database_reference.child("users").child("all_time_user_count").observe(.value, with: { (snapshot) in
            self.all_time_user_count = snapshot.value as! Int
        })
        
    }
    
    private static func listenForUserCount(){
        
        self.database_reference.child("users").child("user_count").observe(.value, with: { (snapshot) in
            self.user_count = snapshot.value as! Int
        })
        
    }
    
    private static func getAllLanguagesFor(_ uid: String, _ user: User, _ closure: @escaping (User?) -> Void) {
        getLanguagesFor(uid: uid, progress: "learn_languages") { (languages) in
            
            guard let languages = languages else {
                return
            }
            
            user.learn_languages = languages
            
        }
        
        getLanguagesFor(uid: uid, progress: "speak_languages") { (languages) in
            
            guard let languages = languages else {
                return
            }
            
            user.speak_languages = languages
            
            closure(user)
        }
    }
    
    private static func transformIntoUserObject(uid: String, user: User, dictionary: NSDictionary, closure: @escaping (User?) -> Void) {
        
        user.firstname = dictionary["firstname"] as! String
        user.lastname = dictionary["lastname"] as! String
        user.birthdate = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: dictionary["birthdate"] as! String)
        user.gender = Gender.toGender(gender: dictionary["gender"] as! String)
        user.country = Country(name: dictionary["country"] as! String)
        user.link_to_profile_image = dictionary["link_to_profile_image"] as! String
        user.discoverable = dictionary["discoverable"] as! Bool
        user.interests = NSAttributedString(string: dictionary["interests"] as! String)
        user.status = NSAttributedString(string: dictionary["status"] as! String)
        
        getAllLanguagesFor(uid, user) { (user) in
            closure(user)
        }
    }
    
    static func getUser(with uid: String, closure: @escaping (User?) -> Void) {
        
        self.database_reference.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? NSDictionary else {
                closure(nil)
                return
            }
            
            
            let user = User()
            
            user.uid = snapshot.key
            
            transformIntoUserObject(uid: uid, user: user, dictionary: dictionary) { (user) in
                closure(user)
            }
        })
        
    }
    
    private static func getUIDOfUser(with number: String, closure: @escaping (String) -> Void) {
        
        self.database_reference.child("users").queryOrdered(byChild: "all_time_user_number").queryEqual(toValue: number).queryLimited(toFirst: 1).observeSingleEvent(of: .value) { (snapshot) in
            
            
            guard let dictionary = snapshot.value as? NSDictionary else {
                return
            }
            
            closure(dictionary.allKeys.first as! String)
            
        }
        
    }
    
    static func getRandomUser(){
        
        var randomNumberID = 1
        var UID = ""
        var current_user: User? = nil
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "taskQueue")
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        dispatchQueue.async {
            
            repeat {

                dispatchGroup.enter()
                
                // Randomly select one user
                randomNumberID = Int.random(in: 1...Internet.all_time_user_count)

                // Transform generated number to uid with which we can retreave the user from the database
                // E.g. "1" -> "iosdnaui29pbpqwbdabd"
                Internet.getUIDOfUser(with: String(randomNumberID)) { (uid) in
                    
                    UID = uid
                    
                    // Download user from database
                    Internet.getUser(with: uid) { (user) in
                        current_user = user
                        
                        dispatchSemaphore.signal()
                        dispatchGroup.leave()
                    }
                }
                
                dispatchSemaphore.wait()

                /// Stay in the loop until we find a user
                /// 1. Whom we don't have yet           `Internet.contains(uid: UID, in: discover_users)`
                /// 2. Who exists in the database        `current_user == nil`
                /// 3. Who wants to be found              `current_user?.discoverable == false`
                /// 4. Who is not us
            } while(current_user == nil || current_user?.discoverable == false || Internet.contains(uid: UID, in: discover_users) || UID == master.uid)
            
            // I want to execute the following line of code when I know that I found an user whith the conditions of the while loop
            discover_users.append(current_user!)
            
            Internet.update_discovery_tableview_delegate?.didUpdate(sender: Internet())
        }
        
        dispatchGroup.notify(queue: dispatchQueue) {
            
            DispatchQueue.main.async {
                print("Another loop iteration finished")
            }
        }
        
    }
    
    private static func contains(uid: String, in users: [User]) -> Bool{
        
        for user in users {
            
            if user.uid == uid {
                return true
            }
            
        }
        
        return false
    }
}
