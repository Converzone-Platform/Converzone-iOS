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
    
    var changingData: ChangingData = .registration
    
    // For adding the user to the websocket
    internal static var addedUserSinceLastConnect = false
    
    //Login Information
    internal static var email: String?
    internal static var password: String?
    
    //All people with whom the master has chats with
    internal static var conversations: [User] = []
    
    //Platform
    internal static var profile_images: UIImage?
    internal static var changed_image: Bool = false
    
    internal static var discoverable: Bool = true
}
