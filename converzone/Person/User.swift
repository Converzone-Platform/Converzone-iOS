//
//  User.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import Foundation

class User: Person {
    
    //Platform Informations
    internal var blocked: Bool = false
    
    //Chats with the Person
    internal var chat: [Message]?
}
