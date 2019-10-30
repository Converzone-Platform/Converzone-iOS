//
//  Master.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import FirebaseAuth

enum ChangingData {
    case editing
    case registration
}

/**
 Master is the main user who is using the device
 */

class Master: Person {
    
    internal var editingMode: ChangingData = .registration
    
    //All people with whom the master has chats with
    internal var conversations: [User] = []
    internal var discoverable: Bool = true
    internal var blocked_users: Set<String> = []
    
    internal var unopened_chats: Int {
        
        var count = 0
        
        for conversation in conversations {
            
            if conversation.openedChat == false{
                count += 1
            }
            
        }
        
        return count
    }
    
    override init(){
        super.init()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        super.uid = uid
    }
    
    func toDictionary() -> [String : Any]{
        
        return [
        
            "firstname": super.firstname,
            "lastname": super.lastname,
            "gender": super.gender!.toString(),
            "birthdate": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: super.birthdate!),
            "country": super.country.name!,
            "device_token": super.device_token,
            "interests": super.interests.string,
            "status": super.status.string,
            "discoverable": self.discoverable
            
        ]
        
    }
}
