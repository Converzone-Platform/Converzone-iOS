//
//  SendingMessages.swift
//  converzone
//
//  Created by Goga Barabadze on 26.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation

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
    
}
