//
//  Reflection.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import Foundation

class Reflection {
    
    internal var text: NSAttributedString?
    internal var user_name: String?
    internal var user_id: String?
    internal var date: Date?
    
    init(text: NSAttributedString, user_name: String, user_id: String, date: Date) {
        
        self.text = text
        self.user_name = user_name
        self.user_id = user_id
        self.date = date
        
    }
}
