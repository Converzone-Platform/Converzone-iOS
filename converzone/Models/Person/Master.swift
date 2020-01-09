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

class Master: Person {
    
    internal var editingMode: ChangingData = .registration
    
    internal var conversations: [User] = []
    
    internal var blocked_users: Set<String> = []
    
    internal var unopened_chats: Int {
        
        var count = 0
        
        for conversation in conversations {
            
            if conversation.openedChat == false {
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
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func toDictionary() -> [String : Any]{
        
        return [
            "firstname": self.firstname,
            "lastname": self.lastname,
            "gender": gender!.toString(),
            "birthdate": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: birthdate!),
            "country": self.country.name,
            "device_token": Internet.fcm_token,
            "interests": self.interests.string,
            "status": self.status.string,
            "discoverable": self.discoverable,
            "phonenumber": self.phonenumber,
            "discover_max_age": self.discover_max_filter_age,
            "discover_min_age": self.discover_min_filer_age,
            "discover_gender_filter": self.discover_gender_filter.toString(),
            "has_donated": self.hasDonated,
            "verified": self.verified
        ]
        
    }
    
}
