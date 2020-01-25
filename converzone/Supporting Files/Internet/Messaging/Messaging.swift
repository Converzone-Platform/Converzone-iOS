//
//  Messaging.swift
//  converzone
//
//  Created by Goga Barabadze on 25.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation
import os
import FirebaseDatabase

extension Internet {
    
    static func send(message: Message, receiver: User){
        
        switch message {
        case is TextMessage: send(message: message as! TextMessage, receiver: receiver)
        case is InformationMessage: send(message: message as! InformationMessage, receiver: receiver)
        default: print("Message type is not supported yet")
        }
        
    }
    
    private static func send(message: TextMessage, receiver: User){
        
        if master.uid.isEmpty || receiver.uid.isEmpty {
            return
        }
        
        let message_id = Date.dateAsTimeIntervalSince1970WithoutDots(date: message.date)
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: receiver.uid)).child("messages").child(message_id).setValue(
            ["sender": master.uid,
             "receiver": receiver.uid,
             "date": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: message.date),
             "text": message.text,
             "type": "TextMessage",
             "opened": false])
        
    }
    
    private static func send(message: InformationMessage, receiver: User){
        
        if master.uid.isEmpty || receiver.uid.isEmpty {
            return
        }
        
        let message_id = Date.dateAsTimeIntervalSince1970WithoutDots(date: message.date)
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: receiver.uid)).child("messages").child(message_id).setValue(
            ["sender": master.uid,
             "receiver": receiver.uid,
             "date": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: message.date),
             "text": message.text!,
             "type": "InformationMessage",
             "opened": false])
        
    }
    
    static func opened(message: Message, sender: User){
        
        // If we sent the message there is no need to set it on read
        if message.is_sender || master.uid.isEmpty || sender.uid.isEmpty {
            return
        }
        
        let message_id = Date.dateAsTimeIntervalSince1970WithoutDots(date: message.date)
        
        self.database_reference.child("conversations").child(generateConversationID(first: master.uid, second: sender.uid)).child("messages").child(message_id).updateChildValues(["opened": true])
        
    }
    
    private static func addUserIfNew(user: User) {
        
        for existing_user in master.conversations {
            
            if user.uid == existing_user.uid {
                return
            }
            
        }
        
        master.conversations.append(user)
    }
    
    /// Find the conversation with the correct partner id and add the message
    private static func findConversationAndAddMessage(message: Message, uid: String, insertPosition: ArrayInsertPosition){
        
        // Iterate through the conversations and find the right person
        for user in master.conversations {
            
            if user.uid == uid {
                
                if insertPosition == .end {
                    user.conversation.append(message)
                }else{
                    user.conversation.insert(message, at: 0)
                }
                
                if user.uid == chatOf.uid{
                    user.openChat()
                }
                
                self.update_chat_tableview_delegate?.didUpdate(sender: Internet(), scrollToBottom: insertPosition == .end)
            }
        }
        
    }
    
    /// Generate one single conversation id out of two user ids
        /// - Parameter first: user id A
        /// - Parameter second: user id B
        
        
        
        
        /// Listener for new conversations. Once it receivers a new conversation it sets a listener for messages in the new conversation
        static func listenForNewConversations(){
            
            if master.uid.isEmpty {
                return
            }
            
            listener_for_new_conversation = self.database_reference.child("users").child(master.uid).child("conversations")
            
            listener_for_new_conversation?.observe(.childAdded) { (snapshot) in

                guard let conversation_id = snapshot.value as? String else {
                    os_log("Could not retreave conversation id")
                    return
                }
                
                Internet.getUser(with: snapshot.key) { (user) in
                    
                    guard let user = user else {
                        os_log("User is empty")
                        return
                    }
                    
                    Internet.addUserIfNew(user: user)
                    
                    self.update_conversations_tableview_delegate?.didUpdate(sender: Internet())
                    
                    // Add a listener to the conversation
                    listenForNewMessageAt(conversationID: conversation_id)
                }
            }

        }
        
        /// Listen for messages in the conversation
        private static func listenForNewMessageAt(conversationID: String){
            
            if master.uid.isEmpty || conversationID.isEmpty {
                return
            }
            
            let message_listener = self.database_reference.child("conversations").child(conversationID).child("messages")
            
            message_listener.queryOrdered(byChild: "date")/*.queryLimited(toLast: 3)*/.observe(.childAdded) { (snapshot) in
                
                let message = snapshot.value as! NSDictionary
                
                receive(message: message, insertPosition: .end)
                
                self.update_conversations_tableview_delegate?.didUpdate(sender: Internet())
                
            }
            
            self.listeners_for_new_messages.append(message_listener)
            
        }
        
        private enum ArrayInsertPosition {
            
            case start
            
            case end
            
        }
        
        static func loadOlderMessages(sender: UIRefreshControl) {
            
    //        let conversationID = generateConversationID(first: master.uid, second: chatOf.uid)
    //
    //        let message_listener = self.database_reference.child("conversations").child(conversationID).child("messages")
    //
    //        // Find last message
    //
    //        chatOf.conversation.forEach { (message) in
    //            print(Date.dateAsTimeIntervalSince1970WithoutDots(date: message.date))
    //            continue
    //        }
    //
    //        guard let last_message_date = chatOf.conversation[safe: 0]?.date else {
    //            os_log("There is no first message.")
    //            return
    //        }
    //
    //        let last_message_id = Date.dateAsTimeIntervalSince1970WithoutDots(date: last_message_date)
    //
    //
    //
    //        message_listener.queryEnding(atValue: last_message_id).queryOrdered(byChild: "reversed_date").queryLimited(toFirst: 7).observe(.childAdded) { (snapshot) in
    //
    //            let message = snapshot.value as! NSDictionary
    //
    //            receive(message: message, insertPosition: .start)
    //
    //            self.update_conversations_tableview_delegate?.didUpdate(sender: Internet())
    //
    //            sender.endRefreshing()
    //        }
            
        }
        
        
        /// Decides what type of message it is and redirects to it's specific function to further handling
        /// - Parameter message: The received message
        private static func receive(message: NSDictionary, insertPosition: ArrayInsertPosition = .end){
            
            guard let type = message["type"] as? String else {
                os_log("Could not extract type from Message.")
                return
            }
            
            switch(type){
            case "TextMessage": receive(textMessage: message, insertPosition: insertPosition)
            case "InformationMessage": receive(informationMessage: message, insertPosition: insertPosition)
            default: os_log("Received Message which is not supported in current version of app.")
            }
            
        }
        
        /// Handles the receiving of a InformationMessages
        /// - Parameter textMessage: The received InformationMessage
        private static func receive(informationMessage: NSDictionary, insertPosition: ArrayInsertPosition){
            
            let sender = informationMessage["sender"] as! String
            let is_sender = sender == master.uid
            
            let text = informationMessage["text"] as! String
            let receiver = informationMessage["receiver"] as! String
            
            let date_string = informationMessage["date"] as! String
            let date = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: date_string)
            
            let opened = informationMessage["opened"] as! Bool
            
            let message = InformationMessage()
            message.text = text
            message.is_sender = is_sender
            message.date = date ?? Date()
            message.opened = opened
            
            findConversationAndAddMessage(message: message, uid: receiver, insertPosition: insertPosition)
            findConversationAndAddMessage(message: message, uid: sender, insertPosition: insertPosition)
            
        }
        
        /// Handles the receiving of a TextMessage
        /// - Parameter textMessage: The received TextMessage
        private static func receive(textMessage: NSDictionary, insertPosition: ArrayInsertPosition){
            
            let sender = textMessage["sender"] as! String
            let is_sender = sender == master.uid
            
            let text = textMessage["text"] as! String
            let receiver = textMessage["receiver"] as! String
            
            let date_string = textMessage["date"] as! String
            let date = Date.stringAsDate(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, string: date_string)
            
            let opened = textMessage["opened"] as! Bool
            
            let message = TextMessage()
            message.text = text
            message.is_sender = is_sender
            message.date = date ?? Date()
            message.opened = opened
            
            findConversationAndAddMessage(message: message, uid: receiver, insertPosition: insertPosition)
            findConversationAndAddMessage(message: message, uid: sender, insertPosition: insertPosition)
            
        }
    
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
    
    private static var listener_for_is_partner_typing: DatabaseReference? = nil
    
    
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
