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

    internal var firstname: String = ""
    internal var lastname: String = ""
    
    internal var discover_max_filter_age = 130
    internal var discover_min_filer_age = 0
    internal var discover_gender_filter = Gender.any
    
    internal var fullname: NSAttributedString {
        
        if #available(iOS 13.0, *) {
            
            let fullString = NSMutableAttributedString(string: firstname + " " + lastname + " ")
            
            if isBirthday {
                let imageAttachment = NSTextAttachment()
                let config = UIImage.SymbolConfiguration(scale: .small)
                
                let image = UIImage(systemName: "gift", withConfiguration: config)
                image?.withBaselineOffset(fromBottom: 1.0)
                imageAttachment.image = image
                fullString.append(NSAttributedString(attachment: imageAttachment))
            }
            
            if verified {
                let imageAttachment = NSTextAttachment()
                let config = UIImage.SymbolConfiguration(scale: .small)
                
                let image = UIImage(systemName: "checkmark.seal", withConfiguration: config)
                image?.withBaselineOffset(fromBottom: 1.0)
                imageAttachment.image = image
                fullString.append(NSAttributedString(attachment: imageAttachment))
            }
            
            if hasDonated {
                let imageAttachment = NSTextAttachment()
                let config = UIImage.SymbolConfiguration(scale: .small)
                
                let image = UIImage(systemName: "heart.fill", withConfiguration: config)
                image?.withBaselineOffset(fromBottom: 1.0)
                imageAttachment.image = image
                fullString.append(NSAttributedString(attachment: imageAttachment))
            }
            
            return fullString
            
        }
        
        return NSMutableAttributedString(string: firstname + " " + lastname)
    }
    
    internal var isBirthday: Bool {
        
        guard let unwrapped_birthdate = self.birthdate else {
            return false
        }

        let bday = unwrapped_birthdate.get(.month, .day)
        let today = Date().get(.month, .day)

        if (bday.month == 2 && bday.day == 29 && bday.isLeapMonth ?? false) {
          return today.month == 3 && today.day == 1
        }

        return bday.month == today.month && bday.day == today.day
    }
    
    internal var verified = false
    internal var hasDonated = false
    internal var gender: Gender? = nil
    internal var birthdate: Date? = nil
    
    internal var age: Int {
        
        guard let birthdate = self.birthdate else {
            return 0
        }
        
        let now = Date()
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: now)
        
        guard let age = ageComponents.year else {
            return 0
        }
        
        return age
        
    }
    
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
    internal var phonenumber: String = ""
    
    init (firstname: String, lastname: String, gender: Gender, birthdate: Date, uid: String){
        self.firstname = firstname
        self.lastname = lastname
        self.gender = gender
        self.birthdate = birthdate
        self.uid = uid
    }
    
    init(){
        
    }
    
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
    
    func toDictionary() -> [String : Any]{
        
        return [
        
            "firstname": self.firstname,
            "lastname": self.lastname,
            "gender": gender!.toString(),
            "birthdate": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: birthdate!),
            "country": self.country.name,
            "device_token": Internet.fcm_token,
            "interests": self.interests.string,
            "status": self.status.string,
            "discoverable": self.discoverable,
            "phonenumber": self.phonenumber,
            "verified": self.verified,
            "discover_max_age": self.discover_max_filter_age,
            "discover_min_age": self.discover_min_filer_age,
            "discover_gender_filter": self.discover_gender_filter.toString(),
            "has_donated": self.hasDonated
        ]
        
    }
}
extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
