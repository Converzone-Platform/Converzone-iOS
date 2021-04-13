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
        
        case browser_introductory_text_shown
    }
    
    
    internal var editingMode: ChangingData = .registration
    
    internal var conversations: [User] = []
    
    internal var blocked_users: Set<String> = []
    
    internal var browser_introductory_text_shown = true
    
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
        browser_introductory_text_shown = try container.decode(Bool.self, forKey: .browser_introductory_text_shown)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: MasterKeys.self)
        
        try container.encode(conversations, forKey: .conversations)
        try container.encode(blocked_users, forKey: .blocked_users)
        try container.encode(browser_introductory_text_shown, forKey: .browser_introductory_text_shown)
    }
    
    override func toDictionary() -> [String : Any] {
        var user_dictionary = super.toDictionary()
        
        user_dictionary.merge([MasterKeys.browser_introductory_text_shown.rawValue : browser_introductory_text_shown]) { (one, two) -> Any in
            return one
        }
        
        return user_dictionary
    }
}
