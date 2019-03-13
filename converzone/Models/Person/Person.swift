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

class Person {
    
    //Personal Details
    internal var firstname: String?
    internal var lastname: String?
    internal var gender: Gender?
    internal var birthdate: Date?
    internal var main_language: Language?
    internal var speak_languages: [Language]? = []
    internal var learn_languages: [Language]? = []
    
    internal var continent: String?
    internal var country: Country?
    
    //Platform Informations
    internal var interests: String?
    internal var status: NSAttributedString?
    internal var link_to_profile_image: URL?
    internal var reflections: [Reflection]? = []
    
    
}
