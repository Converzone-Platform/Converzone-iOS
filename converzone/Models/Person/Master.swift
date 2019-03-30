//
//  Master.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

/*  Master is the main user which is using the device */

import UIKit

class Master: Person {
    
    //Login Information
    internal var email: String
    internal var password: String
    
    //All people with whom the master has chats with
    internal var chats: [User] = []
    
    //Platform
    internal var profile_images: [UIImage]?
    
    init(_ email: String, _ password: String) {
        self.email = email
        self.password = password
        
        super.init(firstname: "Unknown", lastname: "Unknown", gender: .non_binary, birthdate: Date(timeIntervalSince1970: 0))
    }
}


