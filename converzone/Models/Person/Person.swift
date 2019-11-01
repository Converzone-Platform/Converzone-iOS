//
//  Person.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

/* This is a standard class for everyone who is a Person
    The main user and all other users will extend this class later */

import Foundation
import MapKit

class Person {
    
    //Personal Details
    internal var firstname: String = ""
    internal var lastname: String = ""
    
    internal var fullname: String {
        return firstname + " " + lastname
    }
    
    internal var gender: Gender? = nil
    internal var birthdate: Date? = nil
    internal var speak_languages: [Language] = []
    internal var learn_languages: [Language] = []
    
    internal var continent: String = "Europe"
    internal var country: Country = Country(name: "Austria")
    internal var timezone: String = (TimeZone.init(secondsFromGMT: 0)?.abbreviation())!
    internal var interests: NSAttributedString = NSAttributedString(string: "")
    internal var status: NSAttributedString = NSAttributedString(string: "")
    
    internal var link_to_profile_image: String = ""
    internal var reflections: [Reflection] = []
    internal var uid: String = ""
    internal var device_token: String = ""
    internal var discoverable: Bool = true
    
    init (firstname: String, lastname: String, gender: Gender, birthdate: Date, uid: String){
        self.firstname = firstname
        self.lastname = lastname
        self.gender = gender
        self.birthdate = birthdate
        self.uid = uid
    }
    
    init(){
        
    }
    
    //Functionality
    func sortLanguagesAlphabetically(){
        
        self.speak_languages.sort{
            $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
        }
        
        self.learn_languages.sort{
            $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
        }
        
    }
    
    func speakLanguagesToDictionary() -> [String: String] {
        
        return languageArrayToDictionary(array: self.speak_languages)
        
    }
    
    func learnLanguagesToDictionrary() -> [String: String] {
        
        return languageArrayToDictionary(array: self.learn_languages)
        
    }
    
    private func languageArrayToDictionary(array: [Language]) -> [String: String] {
        
        if array.isEmpty { return ["":""] }
        
        var dictionary: [String: String] = [:]
        
        for i in 0...array.count-1 {
            
            dictionary[String(i)] = array[i].name
            
        }
        
        return dictionary
    }
}
