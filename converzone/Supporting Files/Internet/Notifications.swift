//
//  Notifications.swift
//  converzone
//
//  Created by Goga Barabadze on 25.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation
import FirebaseAuth

extension Internet {
    
    static func upload(token: String){
        
        if Auth.auth().currentUser == nil || token.isEmpty || master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).updateChildValues(["device_token": token])
        
    }
    
    static func removeToken(){
        
        if Auth.auth().currentUser == nil || master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).child(Person.Keys.device_token.rawValue).removeValue()
    }
    
}
