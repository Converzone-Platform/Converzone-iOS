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
    
    
    enum ArrayInsertPosition {
        
        case start
        
        case end
        
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
        
        
        
        static func loadOlderMessages(sender: UIRefreshControl) {
            
            let conversationID = generateConversationID(first: master.uid, second: chatOf.uid)
    
            let message_listener = self.database_reference.child("conversations").child(conversationID).child("messages")
    
            // Find last message
            guard let last_message_date = chatOf.conversation[safe: 0]?.date else {
                os_log("There is no first message.")
                return
            }
    
            let last_message_id = Date.dateAsTimeIntervalSince1970WithoutDots(date: last_message_date)
            
            print(last_message_id)
    
            message_listener.queryOrdered(byChild: "reversed_date").queryEnding(atValue: last_message_id).queryLimited(toLast: 7).observe(.childAdded) { (snapshot) in
    
                let message = snapshot.value as! NSDictionary
    
                receive(message: message, insertPosition: .start)
    
                self.update_conversations_tableview_delegate?.didUpdate(sender: Internet())
    
                sender.endRefreshing()
            }
            
        }
    
    /// Find the conversation with the correct partner id and add the message
    static func findConversationAndAddMessage(message: Message, uid: String, insertPosition: ArrayInsertPosition){
        
        // Iterate through the conversations and find the right person
        for user in master.conversations {
            
            if user.uid == uid {
                
                if insertPosition == .end {
                    user.conversation.append(message)
                }else{
                    user.conversation.insert(message, at: 0)
                }
                
                if user.uid == chatOf.uid && UIApplication.currentViewController().self == ChatVC().self {
                    user.openChat()
                }
                
                user.conversation.sort { (message_1, message_2) -> Bool in
                    return message_1.date.timeIntervalSince1970 < message_2.date.timeIntervalSince1970
                }
                
                self.update_chat_tableview_delegate?.didUpdate(sender: Internet(), scrollToBottom: insertPosition == .end)
            }
        }
        
    }
}
