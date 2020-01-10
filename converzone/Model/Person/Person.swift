//
//  Person.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import Foundation
import MapKit

class Person: Codable {
    
    enum Keys: String, CodingKey {
        
        case firstname
        
        case lastname
        
        case discover_max_filter_age
        
        case discover_min_filer_age
        
        case discover_gender_filter
        
        case verified
        
        case has_donated
        
        case gender
        
        case birthdate
        
        case continent
        
        case country
        
        case timezone
        
        case interests
        
        case status
        
        case link_to_profile_image
        
        case uid
        
        case device_token
        
        case discoverable
        
        case phonenumber
        
        case fcm_token
    
    }

    internal var firstname: String = ""
    
    internal var lastname: String = ""
    
    internal var discover_max_filter_age = 130
    
    internal var discover_min_filer_age = 0
    
    internal var discover_gender_filter = Gender.any
    
    internal var verified = false
    
    internal var has_donated = false
    
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
    
    internal var phonenumber: String = ""
    
    internal var fullname: NSAttributedString {
        
        if #available(iOS 13.0, *) {
            
            let fullString = NSMutableAttributedString(string: firstname + " " + lastname + " ")
            
            if isTodayBirthday {
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
            
            if has_donated {
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
    
    internal var isTodayBirthday: Bool {
        
        guard let birthdate = self.birthdate else {
            return false
        }

        let bday = birthdate.get(.month, .day)
        let today = Date().get(.month, .day)

        if (bday.month == 2 && bday.day == 29 && bday.isLeapMonth ?? false) {
          return today.month == 3 && today.day == 1
        }

        return bday.month == today.month && bday.day == today.day
    }
    
    internal var age: Int {
        
        guard let birthdate = self.birthdate else {
            return 1
        }
        
        let now = Date()
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: now)
        
        guard let age = ageComponents.year else {
            return 1
        }
        
        return age
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: Keys.self)
        
        firstname = try container.decode(String.self, forKey: .firstname)
        lastname = try container.decode(String.self, forKey: .lastname)
        discover_max_filter_age = try container.decode(Int.self, forKey: .discover_max_filter_age)
        discover_min_filer_age = try container.decode(Int.self, forKey: .discover_min_filer_age)
        verified = try container.decode(Bool.self, forKey: .verified)
        has_donated = try container.decode(Bool.self, forKey: .has_donated)
        birthdate = try container.decode(Date.self, forKey: .birthdate)
        link_to_profile_image = try container.decode(String.self, forKey: .link_to_profile_image)
        uid = try container.decode(String.self, forKey: .uid)
        device_token = try container.decode(String.self, forKey: .device_token)
        discoverable = try container.decode(Bool.self, forKey: .discoverable)
        phonenumber = try container.decode(String.self, forKey: .phonenumber)
        continent = try container.decode(String.self, forKey: .continent)
        discover_gender_filter = Gender.toGender(gender: try container.decode(String.self, forKey: .discover_gender_filter))
        gender = Gender.toGender(gender: try container.decode(String.self, forKey: .gender))
        country = Country(name: try container.decode(String.self, forKey: .country))
        status = NSAttributedString(string: try container.decode(String.self, forKey: .status))
        interests = NSAttributedString(string: try container.decode(String.self, forKey: .interests))
        
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(firstname, forKey: .firstname)
        try container.encode(lastname, forKey: .lastname)
        try container.encode(discover_max_filter_age, forKey: .discover_max_filter_age)
        try container.encode(discover_min_filer_age, forKey: .discover_min_filer_age)
        try container.encode(verified, forKey: .verified)
        try container.encode(has_donated, forKey: .has_donated)
        try container.encode(link_to_profile_image, forKey: .link_to_profile_image)
        try container.encode(uid, forKey: .uid)
        try container.encode(device_token, forKey: .device_token)
        try container.encode(discoverable, forKey: .discoverable)
        try container.encode(phonenumber, forKey: .phonenumber)
        try container.encode(continent, forKey: .continent)
        try container.encode(discover_gender_filter.toString(), forKey: .discover_gender_filter)
        try container.encode(gender?.toString(), forKey: .gender)
        try container.encode(country.name, forKey: .country)
        try container.encode(status.string, forKey: .status)
        try container.encode(interests.string, forKey: .interests)
        
    }
    
    init() { }
    
    func sort(){

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
        
        if array.isEmpty { return ["" : ""] }
        
        var dictionary: [String: String] = [:]
        
        for i in 0...array.count-1 {
            
            dictionary[String(i)] = array[i].name
            
        }
        
        return dictionary
    }
    
    func toDictionary() -> [String : Any]{
        
        return [
        
            Keys.firstname.rawValue : firstname,
            
            Keys.lastname.rawValue : lastname,
            
            Keys.gender.rawValue : gender!.toString(),
            
            Keys.birthdate.rawValue : Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: birthdate),
            
            Keys.country.rawValue : country.name,
            
            Keys.fcm_token.rawValue : Internet.fcm_token,
            
            Keys.interests.rawValue : interests.string,
            
            Keys.status.rawValue : status.string,
            
            Keys.discoverable.rawValue : discoverable,
            
            Keys.phonenumber.rawValue : phonenumber,
            
            Keys.verified.rawValue : verified,
            
            Keys.discover_max_filter_age.rawValue : discover_max_filter_age,
            
            Keys.discover_min_filer_age.rawValue : discover_min_filer_age,
            
            Keys.discover_gender_filter.rawValue : discover_gender_filter.toString(),
            
            Keys.has_donated.rawValue : has_donated
            
        ]
        
    }
}
