//
//  User.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

class User: Person, Hashable {
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(self.uid)
    }
    
    internal var blocked: Bool = false
    internal var conversation: [Message] = []
    internal var discover_style: Int = 0
    
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
}
