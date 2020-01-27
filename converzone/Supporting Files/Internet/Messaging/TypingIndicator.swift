//
//  TypingIndicator.swift
//  converzone
//
//  Created by Goga Barabadze on 26.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension Internet {
    
    static private func typing(uid: String) {
        
        if master.uid.isEmpty || uid.isEmpty || chatOf.conversation.count == 0 || chatOf.conversation.first is FirstInformationMessage {
            return
        }
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: uid)).child("is_typing").updateChildValues([String(master.uid) : NSDate().timeIntervalSince1970])
    }
    
    static func stoppedTyping(uid: String){
        
        if master.uid.isEmpty || uid.isEmpty || chatOf.conversation.count == 0 || chatOf.conversation.first is FirstInformationMessage {
            return
        }
        
        time_since_last_letter = 0
        
        is_typing_timer?.invalidate()
        is_typing_timer = nil
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: uid)).child("is_typing").updateChildValues([String(master.uid) : 0])
    }
    
    static var is_partner_typing = false {
        didSet{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "listener_for_is_partner_typing"), object: nil)
        }
    }
    
    static func listenForIsTyping(uid: String){
        
        if master.uid.isEmpty {
            return
        }
        
        listener_for_is_partner_typing = self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: uid)).child("is_typing").child(uid)
        
        listener_for_is_partner_typing?.observe(.value, with: { (snapshot) in
            
            guard let time = snapshot.value as? Double else {
                return
            }
            
            if time == 0 || time - NSDate().timeIntervalSince1970 > 8 {
                is_partner_typing = false
            } else {
                is_partner_typing = true
            }
            
        })
    }
    
    static var is_typing_timer: Timer? = nil
    
    static private var time_since_last_letter = 0
    
    static var listener_for_is_partner_typing: DatabaseReference? = nil
    
    static func removeListenerForIsPartnerTyping () {
        self.listener_for_is_partner_typing?.removeAllObservers()
    }
    
    static func startedTyping(uid: String){
        
        is_typing_timer?.invalidate()
        is_typing_timer = nil
        
        typing(uid: uid)
        
        is_typing_timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            
            self.time_since_last_letter += 2
            typing(uid: uid)
            
            if self.time_since_last_letter >= 8 {
                stoppedTyping(uid: uid)
            }
            
        })
        
    }
    
}
