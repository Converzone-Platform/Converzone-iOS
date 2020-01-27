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
    
    static var database_reference = Database.database().reference()
    
    static var storage_reference = Storage.storage().reference()
    
    static var all_time_user_count = 1
    
    static var user_count = 1
    
    static var fcm_token = ""
    
    static var listener_for_new_conversation: DatabaseReference? = nil
    
    static var listener_for_all_time_user_change: DatabaseReference? = nil
    
    static var listener_for_user_count: DatabaseReference? = nil
    
    static var listeners_for_new_messages: [DatabaseReference] = []
    
    
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
        self.removeListenerForIsPartnerTyping()
    }
    
    static func updateBadges() {
        UIApplication.shared.applicationIconBadgeNumber = master.unopened_chats
    }
    
    // MARK: Master
    
    /// Packs all the data from the master and sends it to the database
    static func upload(){
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).updateChildValues(master.toDictionary())
        
    }
    
    static func upload(browser_introductory_text_shown: Bool) {
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).updateChildValues(["browser_introductory_text_shown": browser_introductory_text_shown])
    }
    
    static func donated(){
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).updateChildValues([Person.Keys.has_donated: true])
    }
    
    /// Update the country on the database
    /// - Parameter country: The country to chango to
    static func upload(country: Country){
        self.database_reference.child("users").child(master.uid).updateChildValues([Person.Keys.country : country.name])
    }
    
    static func doesUserExist(uid: String, closure: @escaping (Bool) -> ()) {
        
        if master.uid.isEmpty {
            closure(false)
            return
        }
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
        
        if Auth.auth().currentUser == nil || Navigation.didNotFinishRegistration() || master.uid.isEmpty {
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
    
    
    
    /// Upload profile image to database
    /// - Parameter image: The image to upload
    static func upload(image: UIImage){
        
        if master.uid.isEmpty {
            return
        }
        
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
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).updateChildValues(["link_to_profile_image": linkToProfileImage])
    }
    
    static func upload(discoverMinAge: Int, discoverMaxAge: Int){
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).updateChildValues(["discover_min_filer_age": discoverMinAge, "discover_max_filter_age": discoverMaxAge])
    }
    
    static func upload(discoverGender: Gender) {
        
        if master.uid.isEmpty || discoverGender.toString().isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).updateChildValues(["discover_gender_filter": discoverGender.toString()])
    }
    
    
    // MARK: Languages
    
    
    
    static func generateConversationID(first: String, second: String) -> String{
        
        if first > second {
            
            return first + second
            
        }
        
        return second + first
        
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
    
    
}
