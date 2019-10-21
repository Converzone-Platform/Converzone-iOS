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
    internal var firstname: String?
    internal var lastname: String?
    
    internal var fullname: String?{
        return firstname! + " " + lastname!
    }
    
    internal var gender: Gender?
    internal var birthdate: Date?
    internal var interface_language: Language?
    internal var speak_languages: [Language] = []
    internal var learn_languages: [Language] = []
    
    internal var continent: String?
    internal var country: Country?
    internal var coordinate: CLLocationCoordinate2D?
    internal var timezone: String?
    
    //Platform Informations
    internal var interests: NSAttributedString?
    internal var status: NSAttributedString?
    
    internal var link_to_profile_image: String?
    internal var reflections: [Reflection] = []
    internal var uid: Int?
    
    internal var deviceToken: String?
    
    init (firstname: String, lastname: String, gender: Gender, birthdate: Date, uid: Int){
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
}
