//
//  Master.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import FirebaseAuth

enum ChangingData {
    
    
    case editing
    
    case registration
    
}

class Master: Person {
    
    enum MasterKeys: String, CodingKey {
        
        case conversations
        
        case blocked_users
    }
    
    
    internal var editingMode: ChangingData = .registration
    
    internal var conversations: [User] = []
    
    internal var blocked_users: Set<String> = []
    
    internal var unopened_chats: Int {
        
        var count = 0
        
        for conversation in conversations {
            
            if conversation.openedChat == false {
                count += 1
            }
            
        }
        return count
    }
    
    
    override init(){
        super.init()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        super.uid = uid
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: MasterKeys.self)
        
        conversations = try container.decode([User].self, forKey: .conversations)
        blocked_users = try container.decode(Set<String>.self, forKey: .blocked_users)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: MasterKeys.self)
        
        try container.encode(conversations, forKey: .conversations)
        try container.encode(blocked_users, forKey: .blocked_users)
    }
}
