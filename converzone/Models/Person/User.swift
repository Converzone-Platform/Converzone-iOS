//
//  User.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

class User: Person {
    
    //Platform Informations
    internal var blocked: Bool = false
    internal var small_profile_images: [UIImage]?
    
    //Chats with the Person
    internal var chat: [Message] = []
}
