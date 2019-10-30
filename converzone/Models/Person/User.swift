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
    
    //Platform Informations
    internal var blocked: Bool = false
    internal var small_profile_images: [UIImage]?
    
    //Chats with the Person
    internal var conversation: [Message] = []
    
    // Save if chat was deleted
    internal var deleted_chat: Bool = false
    
    internal var discover_style: Int = 0
    
    internal var openedChat: Bool = false
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
