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
import os

public class Internet: NSObject {
    
    static var update_chat_tableview_delegate: ChatUpdateDelegate?
    
    static var update_conversations_tableview_delegate: ConversationUpdateDelegate?
    
    static var update_discovery_tableview_delegate: DiscoverUpdateDelegate?
    
    private static var database_reference = Database.database().reference()
    
    private static var storage_reference = Storage.storage().reference()
    
    private static var all_time_user_count = 1
    
    static var user_count = 1
    
    static var fcm_token = ""
    
    private static var listener_for_new_conversation: DatabaseReference? = nil
    
    private static var listener_for_all_time_user_change: DatabaseReference? = nil
    
    private static var listener_for_user_count: DatabaseReference? = nil
    
    private static var listeners_for_new_messages: [DatabaseReference] = []
    
    
    /// Set up value listeners for Database
    static func setUpListeners(){
        
        if Auth.auth().currentUser == nil {
            return
        }
        
        removeListeners()
        
        self.listenForNewConversations()
        self.listenForAllTimeUserCountChange()
        self.listenForUserCount()
    }
    
    static func removeListeners(){
        listener_for_user_count?.removeAllObservers()
        listener_for_new_conversation?.removeAllObservers()
        listener_for_all_time_user_change?.removeAllObservers()
        listeners_for_new_messages.removeAll()
    }
    
    // MARK: - Connectivity
    
    /// Return if we have an internet connection. No differenciation with Cellular or Wifi. They are treated the same way
    static func isOnline() -> Bool {
        
        var zero_address = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zero_address.sin_len = UInt8(MemoryLayout.size(ofValue: zero_address))
        zero_address.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zero_address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        guard let default_route_reachability = defaultRouteReachability else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(default_route_reachability, &flags) == false {
            return false
        }
        
        let is_reachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needs_connection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (is_reachable && !needs_connection)
        
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
    
    
    static func signIn(with verificationCode: String, closure: @escaping (Error?) -> Void) {
        
        guard let verification_id = UserDefaults.standard.string(forKey: "verificationID") else {
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verification_id, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
          if error != nil {
            
            closure(error)
            
            return
          }
          
            closure(nil)
            
            guard let uid = Auth.auth().currentUser?.uid else {
                os_log("Firebase's current user isn't initialized")
                return
            }
            
            master.uid = uid
            
            UserDefaults.standard.removeObject(forKey: "verificationID")
        }
        
    }
    
    // MARK: Download and cache image
    
    /// Cache all images in the app
    static let image_cache = NSCache<NSString, UIImage>()
    
    
    /// Download any image from any url
    /// - Parameter url: The url from where to download the image
    /// - Parameter completion: Asynchronously give back the image we retrieved
    private static func downloadImage(withURL url: URL, completion: @escaping (_ image:UIImage?)->()) {
        
        let data_task = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            
            var downloaded_image: UIImage?
            
            if let data = data {
                downloaded_image = UIImage(data: data)
            }
            
            guard let download_image = downloaded_image else {
                os_log("Could not cast data to UIImage")
                return
            }
            
            image_cache.setObject(download_image, forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async {
                completion(downloaded_image)
            }
            
        }
        
        data_task.resume()
    }
    
    /// Check if we need to download the image from the url or if we have it cached
    /// - Parameter url: The url from where to download the image
    /// - Parameter completion: Asynchronously give back the image we retrieved
    static func getImage(withURL url: String, completion: @escaping (_ image:UIImage?)->()) {
        
        guard let url_object = URL(string: url) else{
            return
        }
        
        if let image = image_cache.object(forKey: url as NSString) {
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
        
        let message_id = Date.dateAsTimeIntervalSince1970WithoutDots(date: message.date)
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: receiver.uid)).child("messages").child(message_id).setValue(
            ["sender": master.uid,
             "receiver": receiver.uid,
             "date": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: message.date),
             "text": message.text,
             "type": "TextMessage",
             "opened": false])
        
    }
    
    /// Send the InformationMessage to the database. Firebase Functions will send it to the right user automatically
    /// - Parameter message: The InformationMessage to send
    /// - Parameter receiver: The user who will receive the message
    private static func send(message: InformationMessage, receiver: User){
        
        let message_id = Date.dateAsTimeIntervalSince1970WithoutDots(date: message.date)
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: receiver.uid)).child("messages").child(message_id).setValue(
            ["sender": master.uid,
             "receiver": receiver.uid,
             "date": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: message.date),
             "text": message.text!,
             "type": "InformationMessage",
             "opened": false])
        
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
    
    static func opened(message: Message, sender: User){
        
        // If we sent the message there is no need to set it on read
        if message.is_sender {
            return
        }
        
        let message_id = Date.dateAsTimeIntervalSince1970WithoutDots(date: message.date)
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: sender.uid)).child("messages").child(message_id).updateChildValues(["opened": true])
        
    }
    
    private static func addUserIfNew(user: User) {
        
        for existing_user in master.conversations {
            
            if user.uid == existing_user.uid {
                return
            }
            
        }
        
        master.conversations.append(user)
    }
    
    /// Listener for new conversations. Once it receivers a new conversation it sets a listener for messages in the new conversation
    private static func listenForNewConversations(){
        
        if master.uid.isEmpty {
            return
        }
        
        listener_for_new_conversation = self.database_reference.child("users").child(master.uid).child("conversations")
        
        listener_for_new_conversation?.observe(.childAdded) { (snapshot) in

            guard let conversation_id = snapshot.value as? String else {
                os_log("Could not retreave conversation id")
                return
            }
            
            Internet.getUser(with: snapshot.key) { (user) in
                
                guard let user = user else {
                    os_log("User is empty")
                    return
                }
                
                Internet.addUserIfNew(user: user)
                
                self.update_conversations_tableview_delegate?.didUpdate(sender: Internet())
                
                // Add a listener to the conversation
                listenForNewMessageAt(conversationID: conversation_id)
            }
        }

    }
    
    /// Listen for messages in the conversation
    private static func listenForNewMessageAt(conversationID: String){
        
        if master.uid.isEmpty {
            return
        }
        
        let message_listener = self.database_reference.child("conversations").child(conversationID).child("messages")
            
        message_listener.queryOrdered(byChild: "date").observe(.childAdded) { (snapshot) in
            
            let message = snapshot.value as! NSDictionary
            
            receive(message: message)
            
            self.update_conversations_tableview_delegate?.didUpdate(sender: Internet())
            
        }
        
        self.listeners_for_new_messages.append(message_listener)
        
    }
    
    
    /// Decides what type of message it is and redirects to it's specific function to further handling
    /// - Parameter message: The received message
    private static func receive(message: NSDictionary){
        
        guard let type = message["type"] as? String else {
            os_log("Could not extract type from Message.")
            return
        }
        
        switch(type){
        case "TextMessage": receive(textMessage: message)
        case "InformationMessage": receive(informationMessage: message)
        default: os_log("Received Message which is not supported in current version of app.")
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
        
        let opened = informationMessage["opened"] as! Bool
        
        let message = InformationMessage()
        message.text = text
        message.is_sender = is_sender
        message.date = date
        message.opened = opened
        
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
        
        let opened = textMessage["opened"] as! Bool
        
        let message = TextMessage()
        message.text = text
        message.is_sender = is_sender
        message.date = date
        message.opened = opened
        
        findConversationAndAddMessage(message: message, uid: receiver)
        findConversationAndAddMessage(message: message, uid: sender)
        
    }
    
    static func updateBadges() {
        UIApplication.shared.applicationIconBadgeNumber = master.unopened_chats
    }
    
    /// Find the conversation with the correct partner id and add the message
    private static func findConversationAndAddMessage(message: Message, uid: String){
        
        // Iterate through the conversations and find the right person
        for user in master.conversations {
            
            if user.uid == uid {
                
                user.conversation.append(message)
                
                if user.uid == chatOf.uid{
                    user.openChat()
                }
                
                self.update_chat_tableview_delegate?.didUpdate(sender: Internet())
            }
        }
        
    }
    
    // MARK: Push Notifications
    
    /// Update the Push Notification token to Firebase
    /// - Parameter token: The token to update
    static func upload(token: String){
        
        if Auth.auth().currentUser == nil {
            return
        }
        
        self.database_reference.child("users").child(master.uid).updateChildValues(["device_token": token])
        
    }
    
    static func removeToken(){
        
        if Auth.auth().currentUser == nil {
            return
        }
        
        self.database_reference.child("users").child(master.uid).child("device_token").removeValue()
    }
    
    // MARK: Master
    
    /// Packs all the data from the master and sends it to the database
    static func upload(){
        
        self.database_reference.child("users").child(master.uid).updateChildValues(master.toDictionary())
        
    }
    
    static func donated(){
        self.database_reference.child("users").child(master.uid).updateChildValues(["has_donated": true])
    }
    
    /// Update the country on the database
    /// - Parameter country: The country to chango to
    static func upload(country: Country){
        self.database_reference.child("users").child(master.uid).updateChildValues(["country" : country.name])
    }
    
    static func doesUserExist(uid: String, closure: @escaping (Bool) -> ()) {
        
        self.database_reference.child("users").child(master.uid).child("firstname").observeSingleEvent(of: .value) { (snapshot) in
            
            guard (snapshot.value as? String) != nil else {
                closure(false)
                return
            }
            
            closure(true)
            
        }
    }
    
    /// Get the newest version of the master from the database
    static func getMaster(){
        
        if Auth.auth().currentUser == nil || Navigation.didNotFinishRegistration() {
            return
        }
        
        self.database_reference.child("users").child(master.uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let values = snapshot.value as? NSDictionary else {
                return
            }
            
            transformIntoMasterObject(dictionary: values)
            
        }
        
        // Get List of blocked users
        Internet.getBlockedUsers()
        
    }
    
    /// User was logged out (or logged in)
    private static func listenForDidChangeAuthState(){
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if user == nil {
                
                Internet.signOut()
                
            }
            
        }
        
    }
    
    static func signOut(){
        
        do{
            try Auth.auth().signOut()
            
            discover_users.removeAll()
            Internet.removeListeners()
            
            Internet.removeToken()
            
            master = Master()
            
            UserDefaults.standard.removeObject(forKey: "DidFinishRegistration")
            
        }catch{
            alert("Signing out...", "An unknown error occurred")
        }
    }
    
    /// Upload profile image to database
    /// - Parameter image: The image to upload
    static func upload(image: UIImage){
        
        guard let jpeg = image.jpegData(compressionQuality: 1) else {
            os_log("Could not extract JPEG from image")
            return
        }
        
        storage_reference.child("profile_images").child(master.uid + ".jpg").putData(jpeg, metadata: nil) { (metadata, error) in
            
            if error != nil {
                
                alert("Image upload went wrong", error!.localizedDescription)
                return
            }
            
            self.storage_reference.child("/profile_images/" + master.uid + ".jpg").downloadURL { (url, error) in
                
                if error != nil {
                    return
                }
                
                guard let url_link = url?.absoluteString else {
                    os_log("Could not extract URL LINK from url")
                    return
                }
                
                master.link_to_profile_image = url_link
                Internet.upload(linkToProfileImage: url_link)
            }
        }
    }
    
    ///  link to profile image to Firebase Database
    /// - Parameter linkToProfileImage: Link to be uploaded
    private static func upload(linkToProfileImage: String){
        self.database_reference.child("users").child(master.uid).updateChildValues(["link_to_profile_image": linkToProfileImage])
    }
    
    static func upload(discoverMinAge: Int, discoverMaxAge: Int){
        self.database_reference.child("users").child(master.uid).updateChildValues(["discover_min_age": discoverMinAge, "discover_max_age": discoverMaxAge])
    }
    
    static func upload(discoverGender: Gender) {
        self.database_reference.child("users").child(master.uid).updateChildValues(["discover_gender_filter": discoverGender.toString()])
    }
    
    /// Transforms the dictionary to master
    private static func transformIntoMasterObject (dictionary: NSDictionary) {
        
        guard
            let firstname = dictionary[Person.Keys.firstname.rawValue] as? String,
            let lastname = dictionary[Person.Keys.lastname.rawValue] as? String,
            let birthdate = dictionary[Person.Keys.birthdate.rawValue] as? String,
            let gender = dictionary[Person.Keys.gender.rawValue] as? String,
            let country = dictionary[Person.Keys.country.rawValue] as? String,
            let link_to_profile_image = dictionary[Person.Keys.link_to_profile_image.rawValue] as? String,
            let discoverable = dictionary[Person.Keys.discoverable.rawValue] as? Bool,
            let interests = dictionary[Person.Keys.interests.rawValue] as? String,
            let status = dictionary[Person.Keys.status.rawValue] as? String,
            let phonenumber = dictionary[Person.Keys.phonenumber.rawValue] as? String,
            let discover_min_age = dictionary[Person.Keys.discover_min_filer_age.rawValue] as? Int,
            let discover_max_age = dictionary[Person.Keys.discover_max_filter_age.rawValue] as? Int,
            let discover_gender_filter = dictionary[Person.Keys.discover_gender_filter.rawValue] as? String,
            let has_donated = dictionary[Person.Keys.has_donated.rawValue] as? Bool,
            let verified = dictionary[Person.Keys.verified.rawValue] as? Bool
        else {
            
            os_log("Received master object is incomplete")
            
            return
        }
        
        master.firstname = firstname
        master.lastname = lastname
        master.gender = Gender.toGender(gender: gender)
        master.birthdate = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: birthdate)
        master.country = Country(name: country)
        master.link_to_profile_image = link_to_profile_image
        master.discoverable = discoverable
        master.interests = NSAttributedString(string: interests)
        master.status = NSAttributedString(string: status)
        master.phonenumber = phonenumber
        master.discover_min_filer_age = discover_min_age
        master.discover_max_filter_age = discover_max_age
        master.discover_gender_filter = Gender.toGender(gender: discover_gender_filter)
        master.has_donated = has_donated
        master.verified = verified
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
    
    static func upload(potentiallyNeedsHelp: Bool, user: String){
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: user)).child("settings").setValue(["potentially_needs_help" : potentiallyNeedsHelp])
        
        
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
    
    static func getBlockedUsers(){
        self.database_reference.child("users").child(master.uid).child("blockee").observe(.value) { (snapshot) in
            
            guard let blocked_users = snapshot.value as? Array<String> else {
                return
            }
            
            master.blocked_users = Set(blocked_users)
            
        }
    }
    
    // MARK: Discovery
    
    private static func listenForAllTimeUserCountChange(){
        
        listener_for_all_time_user_change = self.database_reference.child("users").child("all_time_user_count")
        
        listener_for_all_time_user_change?.observe(.value, with: { (snapshot) in
            guard let count = snapshot.value as? Int else{
                os_log("Could not extract count.")
                return
            }
            self.all_time_user_count = count
        })
        
    }
    
    private static func listenForUserCount(){
        
        listener_for_user_count = self.database_reference.child("users").child("user_count")
        
        listener_for_user_count?.observe(.value, with: { (snapshot) in
            
            guard let count = snapshot.value as? Int else {
                os_log("Could not extract count.")
                return
            }
            self.user_count = count
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
        
        guard
            
            let firstname = dictionary[Person.Keys.firstname.rawValue] as? String,
            let lastname = dictionary[Person.Keys.lastname.rawValue] as? String,
            let birthdate = dictionary[Person.Keys.birthdate.rawValue] as? String,
            let gender = dictionary[Person.Keys.gender.rawValue] as? String,
            let country = dictionary[Person.Keys.country.rawValue] as? String,
            let link_to_profile_image = dictionary[Person.Keys.link_to_profile_image.rawValue] as? String,
            let discoverable = dictionary[Person.Keys.discoverable.rawValue] as? Bool,
            let interests = dictionary[Person.Keys.interests.rawValue] as? String,
            let status = dictionary[Person.Keys.status.rawValue] as? String,
            let phonenumber = dictionary[Person.Keys.phonenumber.rawValue] as? String,
            let discover_min_age = dictionary[Person.Keys.discover_min_filer_age.rawValue] as? Int,
            let discover_max_age = dictionary[Person.Keys.discover_max_filter_age.rawValue] as? Int,
            let discover_gender_filter = dictionary[Person.Keys.discover_gender_filter.rawValue] as? String,
            let has_donated = dictionary[Person.Keys.has_donated.rawValue] as? Bool,
            let verified = dictionary[Person.Keys.verified.rawValue] as? Bool
            
        else {
            
            os_log("Received master object is incomplete")
            
            return
        }
        
        user.firstname = firstname
        user.lastname = lastname
        user.birthdate = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: birthdate)
        user.gender = Gender.toGender(gender: gender)
        user.country = Country(name: country)
        user.link_to_profile_image = link_to_profile_image
        user.discoverable = discoverable
        user.interests = NSAttributedString(string: interests)
        user.status = NSAttributedString(string: status)
        user.phonenumber = phonenumber
        user.has_donated = has_donated
        user.verified = verified
        user.discover_min_filer_age = discover_min_age
        user.discover_max_filter_age = discover_max_age
        master.discover_gender_filter = Gender.toGender(gender: discover_gender_filter)
        
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
    
    static func getUIDOfUser(with number: String, closure: @escaping (String) -> Void) {
        
        self.database_reference.child("users").queryOrdered(byChild: "all_time_user_count").queryEqual(toValue: number).queryLimited(toFirst: 1).observeSingleEvent(of: .value) { (snapshot) in
            
            
            guard let dictionary = snapshot.value as? NSDictionary else {
                os_log("Could not retreave dictionary.")
                return
            }
            
            guard let uid = dictionary.allKeys.first as? String else {
                os_log("Could not retreave uid.")
                return
            }
            
            closure(uid)
            
        }
        
    }
    
    static private func randomDiscoverStyle(for user: User){
        if user.status.string.count > 10 && Int.random(in: 0...100) >= 80 {
            user.discover_style = 1
            return
        }
    }
    
    static func getRandomUser(){
        
        if no_discoverable_users_left {
            return
        }
        
        // Randomly select one user until we find someone we didn't have before
        let random_number_id = String(Int.random(in: 1...Internet.all_time_user_count))
        
        // Transform generated number to uid with which we can retreave the user from the database
        // E.g. "1" -> "iosdnaui29pbpqwbdabd"
        Internet.getUIDOfUser(with: random_number_id) { (uid) in
            
            // Download user from database
            Internet.getUser(with: uid) { (user) in
                
                if uid == master.uid ||
                    user == nil ||
                    discover_users.contains(user!) ||
                    user?.discoverable == false ||
                    master.blocked_users.contains(user!.uid) ||
                    user?.birthdate == nil ||
                    user!.age < master.discover_min_filer_age ||
                    user!.age > master.discover_max_filter_age ||
                    !(master.discover_gender_filter == .any || user?.gender == master.discover_gender_filter) ||
                    
                    master.age < user!.discover_min_filer_age ||
                    user!.age > user!.discover_max_filter_age ||
                    !(user?.discover_gender_filter == .any || master.gender == user?.discover_gender_filter)
                    {
                    Internet.getRandomUser()
                }else{
                    
                    randomDiscoverStyle(for: user!)
                    discover_users.insert(user!)
                    
                    fetchedCount += 1
                    
                    Internet.update_discovery_tableview_delegate?.didUpdate(sender: Internet())
                    
                }
                
            }
        }
        
    }
    
    // MARK: IsTyping
    
    static var is_typing_timer: Timer? = nil
    
    static private var time_since_last_letter = 0
    
    private static var listener_for_is_partner_typing: DatabaseReference? = nil
    
    
    static func startedTyping(uid: String){
        
        is_typing_timer?.invalidate()
        is_typing_timer = nil
        
        typing(uid: uid)
        
        is_typing_timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            
            self.time_since_last_letter += 2
            typing(uid: uid)
            
            if self.time_since_last_letter >= 8 {
                stoppedTyping(uid: uid)
            }
            
        })
        
    }
    
    static private func typing(uid: String) {
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: uid)).child("isTyping").updateChildValues([String(master.uid) : NSDate().timeIntervalSince1970])
    }
    
    static func stoppedTyping(uid: String){
        
        time_since_last_letter = 0
        
        is_typing_timer?.invalidate()
        is_typing_timer = nil
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: uid)).child("is_typing").updateChildValues([String(master.uid) : 0])
    }
    
    static var is_partner_typing = false {
        didSet{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "listener_for_is_partner_typing"), object: nil)
        }
    }
    
    static func listenForIsTyping(uid: String){
        
        listener_for_is_partner_typing = self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: uid)).child("is_typing").child(uid)
        
        listener_for_is_partner_typing?.observe(.value, with: { (snapshot) in
            
            guard let time = snapshot.value as? Double else {
                return
            }
            
            if time == 0 || time - NSDate().timeIntervalSince1970 > 8 {
                is_partner_typing = false
            } else {
                is_partner_typing = true
            }
            
        })
    }
    
}
