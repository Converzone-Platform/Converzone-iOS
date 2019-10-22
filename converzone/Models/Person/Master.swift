//
//  Master.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

enum ChangingData {
    case editing
    case registration
}

/**
 Master is the main user who is using the device
 */

class Master: Person {
    
    internal var changingData: ChangingData = .registration
    
    //Login Information
    internal var email: String?
    internal var password: String?
    
    //All people with whom the master has chats with
    internal var conversations: [User] = []
    
    // Platform
    internal var interface_language: Language?
    internal var discoverable: Bool = true
    
    init(email: String, password: String){
        self.email = email
        self.password = password
        
        super.init()
    }
    
    func toDictionary() -> [String : Any]{
        
        return [
        
            "firstname": super.firstname!,
            "lastname": super.lastname!,
            "gender": super.gender?.toString(),
            "birthdate": Date.dateAsString(style: .dayMonthYearHourMinuteSecondMillisecondTimezone, date: super.birthdate!),
            "country": super.country?.name!,
            "link_to_profile_image": super.link_to_profile_image!,
            "device_token": super.device_token,
            "interests": super.interests?.string,
            "status": super.status?.string,
            
            "telephone": self.email!,
            "discoverable": self.discoverable,
            "interface_language": self.interface_language?.name
            
        ]
        
    }
}
