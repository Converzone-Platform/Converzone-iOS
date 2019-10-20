//
//  Master.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

/*  Master is the main user who is using the device */

import UIKit

enum ChangingData {
    case editing
    case registration
}

class Master: Person {
    
    static var changingData: ChangingData = .registration
    
    // For adding the user to the websocket
    static internal var addedUserSinceLastConnect = false
    
    //Login Information
    static internal var email: String?
    static internal var password: String?
    
    //All people with whom the master has chats with
    static internal var conversations: [User] = []
    
    //Platform
    static internal var profile_images: UIImage?
    static internal var changed_image: Bool = false
    
    static internal var discoverable: Bool = true
    
}
