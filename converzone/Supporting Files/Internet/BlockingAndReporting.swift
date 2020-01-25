//
//  BlockingAndReporting.swift
//  converzone
//
//  Created by Goga Barabadze on 25.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation

extension Internet {
    
    /// Block an user locally and on the database
    /// - Parameter userid: User's uid to be blocked
    static func block(userid: String){
        
        if master.uid.isEmpty {
            return
        }
        
        master.blocked_users.insert(userid)
        
        self.database_reference.child("users").child(master.uid).child("blockee").setValue(Array(master.blocked_users))
        
    }
    
    /// Unblock an user locally and on the database
    /// - Parameter userid: User's uid to be unblocked
    static func unblock(userid: String){
        
        if master.uid.isEmpty {
            return
        }
        
        master.blocked_users.remove(userid)
        
        self.database_reference.child("users").child(master.uid).child("blockee").setValue(Array(master.blocked_users))
    }
    
    static func getBlockedUsers(){
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).child("blockee").observe(.value) { (snapshot) in
            
            guard let blocked_users = snapshot.value as? Array<String> else {
                return
            }
            
            master.blocked_users = Set(blocked_users)
            
        }
    }
    
    // MARK: Blocking and reporting users
    
    /// Report a person
    /// - Parameter userid: The  uid of the person to be reported
    /// - Parameter reason: Reson of report
    static func report(userid: String, reason: String){
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("users").child(master.uid).child("reportee").child(userid).setValue(["reason" : reason])
        
    }
    
    static func upload(potentiallyNeedsHelp: Bool, user: String){
        
        if master.uid.isEmpty {
            return
        }
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: user)).child("settings").setValue(["potentially_needs_help" : potentiallyNeedsHelp])
        
        
    }
}
