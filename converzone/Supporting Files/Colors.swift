//
//  Colors.swift
//  converzone
//
//  Created by Goga Barabadze on 01.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

enum Colors {
    
    static let red = UIColor.systemRed
    
    static let orange = UIColor.systemOrange
    
    static let yellow = UIColor.systemYellow
    
    static let green = UIColor.systemGreen
    
    static let light_blue = UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 1.0)
    
    static let blue = UIColor.systemBlue
    
    static let violet = UIColor.systemPurple
    
    static let pink = UIColor.systemPurple
    
    static let white = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    
    static let black = UIColor(red: 0.00, green: 0.0, blue: 0.0, alpha: 1.0)
    
    static let grey = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
    
    static let darkGrey = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    
    static let background_grey = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    
    
    static func random() -> UIColor {
        
        switch Int.random(in: 0...5) {
            
        case 0: return Colors.orange
            
        case 1: return Colors.yellow
            
        case 2: return Colors.green
            
        case 3: return Colors.blue
            
        case 4: return Colors.violet
            
        case 5: return Colors.pink
        
        default: fatalError()
            
        }
    }
}
