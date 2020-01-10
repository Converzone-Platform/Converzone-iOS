//
//  User.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

class User: Person, Hashable {
    
    enum UserKeys: String, CodingKey {
        
        case blocked
        
        case conversation
    }
    
    
    internal var blocked: Bool = false
    
    internal var conversation: [Message] = []
    
    internal var discover_style: Int = 0
    
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.uid)
    }
    
    internal var openedChat: Bool {
        
        set {
            
            conversation.forEach { (message) in
                message.opened = true
            }
            
        }
        
        get {
            
            var opened = false
            
            conversation.forEach { (message) in
                if message.opened {
                    opened = true
                }
            }
            
            return opened
        }
    }
    
    internal func openChat(){
        
        conversation.forEach { (message) in
            message.opened = true
            Internet.opened(message: message, sender: self)
        }
    }
    
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: UserKeys.self)
        
        blocked = try container.decode(Bool.self, forKey: .blocked)
        conversation = try container.decode([Message].self, forKey: .conversation)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: UserKeys.self)
        
        try container.encode(blocked, forKey: .blocked)
        try container.encode(conversation, forKey: .conversation)
    }
    
    override init() {
        super.init()
    }
}
