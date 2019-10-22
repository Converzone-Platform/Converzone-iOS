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
    
    // Maybe "weak" here?!
    static var chat_delegate: ChatUpdateDelegate?
    static var conversations_delegate: ConversationUpdateDelegate?
    
    static var dat_ref = Database.database().reference()
    static var sto_ref = Storage.storage().reference()
    
    class func configure(){
        
        self.listenForNewConversations()
        
    }
    
    // MARK: - Connectivity
    
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
    
    // MARK: Download and cache image
    
    static let imageCache = NSCache<NSString, UIImage>()
    
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
    
    static func getImage(withURL url: String, completion: @escaping (_ image:UIImage?)->()) {
        if let image = imageCache.object(forKey: url as NSString) {
            completion(image)
        } else {
            downloadImage(withURL: URL(string: url)!, completion: completion)
        }
    }
    
    // MARK: - Sending messages
    static func send(message: Message, receiver: User){
        
        switch message {
        case is TextMessage: send(message: message as! TextMessage, receiver: receiver)
        default: print("Message type is not supported yet")
        }
        
    }
    
    private static func send(message: TextMessage, receiver: User){
        
        self.dat_ref.child("conversations").child(generateConversationID(first: master.uid!, second: receiver.uid!)).child("messages").child(String(message.hashValue)).setValue(["sender": master.uid!, "receiver": receiver.uid!, "date": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: message.date!), "text": message.text!, "type": "TextMessage"])
        
    }
    
    /**
     Takes the alphabetically higher and adds the alphabetically lower id at the end
     */
    private static func generateConversationID(first: String, second: String) -> String{
        
        if first > second {
            
            return first + second
            
        }
        
        return second + first
        
    }
    
    // MARK: Receiving messages
    
    private static func listenForNewConversations(){

        self.dat_ref.child("users").child(master.uid!).child("conversations").observe(.childAdded) { (snapshot) in

            let conversationid = snapshot.value as! String
            //let partnerid = snapshot.key
            
            // MARK: TODO - Save new user and get their data
            
            // Add a listener to the conversation
            listenForNewMessageAt(conversationID: conversationid)
            
        }

    }
    
    private static func listenForNewMessageAt(conversationID: String){
        
        self.dat_ref.child("conversations").child(conversationID).child("messages").queryOrdered(byChild: "date").queryLimited(toLast: 10).observe(.childAdded) { (snapshot) in
            
            let message = snapshot.value as! NSDictionary
            
            receive(message: message)
            
        }
        
    }
    
    ///Takes a message as a prameter and decides what kind of message it is. Afterwards it directs the message to a function which can actually handle it
    private static func receive(message: NSDictionary){
        
        let type = message["type"] as! String
        
        switch(type){
        case "TextMessage": receive(textMessage: message)
        default: print("Message type is not supported yet")
        }
        
    }
    
    /**
     Takes a Dictionary and transforms it into a TextMessage object
     */
    private static func receive(textMessage: NSDictionary){
        
        let sender = textMessage["sender"] as! String
        let isSender = sender == master.uid!
        
        // MARK: TODO - If I am the sender and I receive the message back we can say that it works as a sent indicator for messages
        if isSender{
            
        }
        
        let text = textMessage["text"] as! String
        let receiver = textMessage["receiver"] as! String
        
        let date_string = textMessage["date"] as! String
        let date = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: date_string)
        
        let message = TextMessage()
        message.text = text
        message.is_sender = isSender
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
                
                self.chat_delegate?.didUpdate(sender: Internet())
                
            }
            
        }
        
    }
    
    // MARK: Master update
    
    /// Packs all the data from the master and sends it to the database
    static func upload(){
        
        self.dat_ref.child("users").child(master.uid!).updateChildValues(master.toDictionary())
        
    }
    
    static func upload(country: Country){
        
        self.dat_ref.child("users").child(master.uid!).updateChildValues(["country" : country.name!])
        
    }
    
    static func getMaster(){
        
        self.dat_ref.child("users").child(master.uid!).observeSingleEvent(of: .value) { (snapshot) in
            
            let values = snapshot.value as! NSDictionary
            
            transformIntoMasterObject(dictionary: values)
            
        }
        
    }
    
    static func upload(image: UIImage){
        
        let jpeg = image.jpegData(compressionQuality: 1.0)
        
        sto_ref.child("profile_images").child(master.uid! + ".jpg").putData(jpeg!, metadata: nil) { (metadata, error) in
            
            if error != nil {
                
                alert("Image upload went wrong", error!.localizedDescription, UIApplication.getPresentedViewController()!)
                
            }
            
        }
        
        self.sto_ref.child("/profile_images/" + master.uid! + ".jpg").downloadURL { (url, error) in
            
            master.link_to_profile_image = url?.absoluteString
            
        }
        
    }
    
    /// Transforms the dictionary to master
    private static func transformIntoMasterObject (dictionary: NSDictionary) {
        
        master.firstname = dictionary["firstname"] as? String
        master.lastname = dictionary["lastname"] as? String
        master.gender = Gender.toGender(gender: dictionary["gender"] as! String)
        master.birthdate = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: dictionary["birthdate"] as! String)
        master.country = Country(name: dictionary["country"] as! String)
        master.link_to_profile_image = dictionary["link_to_profile_image"] as? String
        master.device_token = dictionary["device_token"] as! String
        master.email = dictionary["telephone"] as? String
        master.discoverable = dictionary["discoverable"] as! Bool
        master.interface_language = Language(name: dictionary["interface_language"] as! String)
        master.interests = NSAttributedString(string: dictionary["interests"] as! String)
        master.status = NSAttributedString(string: dictionary["status"] as! String)
        
    }
    
    // MARK: Languages
    
    static func uploadLanguages(){
        
        Internet.removeLanguages()
        
        self.dat_ref.child("users").child(master.uid!).child("speak_languages").setValue(master.speakLanguagesToDictionary())
        
        if master.learn_languages.count == 0 { return }
        
        self.dat_ref.child("users").child(master.uid!).child("learn_languages").setValue(master.learnLanguagesToDictionrary())
    }
    
    private static func removeLanguages(){
        
        self.dat_ref.child("users").child(master.uid!).child("speak_languages").removeValue()
        self.dat_ref.child("users").child(master.uid!).child("learn_languages").removeValue()
        
    }
    
    static func getLanguagesFor(uid: String, progress: String, closure: @escaping ([Language]?) -> Void){
        
        self.dat_ref.child("users").child(uid).child(progress).observeSingleEvent(of: .value) { (snapshot) in
            
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
    
}
