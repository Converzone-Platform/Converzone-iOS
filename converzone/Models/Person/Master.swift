//
//  Master.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

/*  Master is the main user who is using the device */

import UIKit

class Master: Person {
    
    //Login Information
    internal var email: String
    internal var password: String
    
    //All people with whom the master has chats with
    internal var conversations: [User] = []
    
    //Platform
    internal var profile_images: [UIImage]?
    
    internal var discoverable: Bool = true
    
    init(_ email: String, _ password: String) {
        self.email = email
        self.password = password
        
        super.init(firstname: "Unknown", lastname: "Unknown", gender: .non_binary, birthdate: Date(timeIntervalSince1970: 0), uid: 1)
    }
    
    // Get count of conversations which were deleted
    internal var count_hidden_conversations: Int{
        get{
            var count = 0
            
            for conversation in conversations{
                if conversation.conversation.count == 0{
                    count+=1
                }
            }
            
            return count
        }
    }
}


