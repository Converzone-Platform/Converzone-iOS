//
//  ParsingUsers.swift
//  converzone
//
//  Created by Goga Barabadze on 25.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation
import os

extension Internet {
    
    static func transformIntoUserObject(uid: String, user: User, dictionary: NSDictionary, closure: @escaping (User?) -> Void) {
        
        if let firstname = dictionary[Person.Keys.firstname.rawValue] as? String {
            user.firstname = firstname
        }
        
        if let lastname = dictionary[Person.Keys.lastname.rawValue] as? String {
            user.lastname = lastname
        }
        
        if let gender = dictionary[Person.Keys.gender.rawValue] as? String {
            user.gender = Gender.toGender(gender: gender)
        }
        
        if let birthdate = dictionary[Person.Keys.birthdate.rawValue] as? String {
            user.birthdate = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: birthdate)
        }
        
        if let country = dictionary[Person.Keys.country.rawValue] as? String {
            user.country = Country(name: country)
        }
        
        if let link_to_profile_image = dictionary[Person.Keys.link_to_profile_image.rawValue] as? String {
            user.link_to_profile_image = link_to_profile_image
        }
        
        if let discoverable = dictionary[Person.Keys.discoverable.rawValue] as? Bool {
            user.discoverable = discoverable
        }
        
        if let interests = dictionary[Person.Keys.interests.rawValue] as? String {
            user.interests = NSAttributedString(string: interests)
        }
        
        if let status = dictionary[Person.Keys.status.rawValue] as? String {
            user.status = NSAttributedString(string: status)
        }
        
        if let discover_min_age = dictionary[Person.Keys.discover_min_filer_age.rawValue] as? Int {
            user.discover_min_filter_age = discover_min_age
        }
        
        if let discover_max_age = dictionary[Person.Keys.discover_max_filter_age.rawValue] as? Int {
            user.discover_max_filter_age = discover_max_age
        }
        
        if let discover_gender_filter = dictionary[Person.Keys.discover_gender_filter.rawValue] as? String {
            user.discover_gender_filter = Gender.toGender(gender: discover_gender_filter)
        }
        
        if let has_donated = dictionary[Person.Keys.has_donated.rawValue] as? Bool {
            user.has_donated = has_donated
        }
        
        if let verified = dictionary[Person.Keys.verified.rawValue] as? Bool {
            user.verified = verified
        }
        
        getAllLanguagesFor(uid, user) { (user) in
            closure(user)
        }
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
    
    /// Upload Languages of the master to the database
    static func uploadLanguages(){
        
        if master.uid.isEmpty {
            return
        }
        
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
        
        if uid.isEmpty {
            return
        }
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
    
    static func getUser(with uid: String, closure: @escaping (User?) -> Void) {
        
        if uid.isEmpty {
            return
        }
        
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
        
        if number.isEmpty {
            return
        }
        
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
    
    /// Transforms the dictionary to master
    static func transformIntoMasterObject (dictionary: NSDictionary) {
        
        if let firstname = dictionary[Person.Keys.firstname.rawValue] as? String {
            master.firstname = firstname
        }
        
        if let lastname = dictionary[Person.Keys.lastname.rawValue] as? String {
            master.lastname = lastname
        }
        
        if let gender = dictionary[Person.Keys.gender.rawValue] as? String {
            master.gender = Gender.toGender(gender: gender)
        }
        
        if let birthdate = dictionary[Person.Keys.birthdate.rawValue] as? String {
            master.birthdate = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: birthdate)
        }
        
        if let country = dictionary[Person.Keys.country.rawValue] as? String {
            master.country = Country(name: country)
        }
        
        if let link_to_profile_image = dictionary[Person.Keys.link_to_profile_image.rawValue] as? String {
            master.link_to_profile_image = link_to_profile_image
        }
        
        if let discoverable = dictionary[Person.Keys.discoverable.rawValue] as? Bool {
            master.discoverable = discoverable
        }
        
        if let interests = dictionary[Person.Keys.interests.rawValue] as? String {
            master.interests = NSAttributedString(string: interests)
        }
        
        if let status = dictionary[Person.Keys.status.rawValue] as? String {
            master.status = NSAttributedString(string: status)
        }
        
        if let phonenumber = dictionary[Person.Keys.phonenumber.rawValue] as? String {
             master.phonenumber = phonenumber
        }
        
        if let discover_min_age = dictionary[Person.Keys.discover_min_filer_age.rawValue] as? Int {
            master.discover_min_filter_age = discover_min_age
        }
        
        if let discover_max_age = dictionary[Person.Keys.discover_max_filter_age.rawValue] as? Int {
            master.discover_max_filter_age = discover_max_age
        }
        
        if let discover_gender_filter = dictionary[Person.Keys.discover_gender_filter.rawValue] as? String {
            master.discover_gender_filter = Gender.toGender(gender: discover_gender_filter)
        }
        
        if let has_donated = dictionary[Person.Keys.has_donated.rawValue] as? Bool {
            master.has_donated = has_donated
        }
        
        if let verified = dictionary[Person.Keys.verified.rawValue] as? Bool {
            master.verified = verified
        }
        
        if let browser_introductory_text_shown = dictionary["browser_introductory_text_shown"] as? Bool {
            master.browser_introductory_text_shown = browser_introductory_text_shown
        }
    }
    
}
