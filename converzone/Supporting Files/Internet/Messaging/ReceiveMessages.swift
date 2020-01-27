//
//  ReceiveMessages.swift
//  converzone
//
//  Created by Goga Barabadze on 26.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation
import os

extension Internet {
    
    /// Decides what type of message it is and redirects to it's specific function to further handling
    /// - Parameter message: The received message
    static func receive(message: NSDictionary, insertPosition: ArrayInsertPosition = .end){
        
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
    static func receive(informationMessage: NSDictionary, insertPosition: ArrayInsertPosition){
        
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
    
    
    
}
