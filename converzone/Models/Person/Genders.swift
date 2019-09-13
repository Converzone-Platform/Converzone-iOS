//
//  Genders.swift
//  converzone
//
//  Created by Goga Barabadze on 15.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import Foundation

let genderStrings = ["female", "male", "non binary"]

enum Gender: Int, CaseIterable {
    
    case female
    case male
    case non_binary
    
    func toString() -> String {
        return genderStrings[self.rawValue]
    }
    
    static func toGender(gender: String) -> Gender {
        
        switch gender {
            
        case "f":
            fallthrough
        case "female":
            return Gender.female
           
        case "m":
            fallthrough
        case "male":
            return Gender.male
            
        default:
            return Gender.non_binary
        }
        
    }
}
