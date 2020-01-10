//
//  Colors.swift
//  converzone
//
//  Created by Goga Barabadze on 01.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

enum Colors {
    
    static let red = UIColor(red: 255/255, green: 59/255, blue: 49/255, alpha: 1.0)
    
    static let orange = UIColor(red: 255/255, green: 149/255, blue: 1/255, alpha: 1.0)
    
    static let yellow = UIColor(red: 255/255, green: 204/255, blue: 1/255, alpha: 1.0)
    
    static let green = UIColor(red: 76/255, green: 217/255, blue: 101/255, alpha: 1.0)
    
    static let light_blue = UIColor(red: 90/255, green: 200/255, blue: 251/255, alpha: 1.0)
    
    static let blue = UIColor(hex: 0x007AFA)
    
    static let violet = UIColor(red: 88/255, green: 86/255, blue: 215/255, alpha: 1.0)
    
    static let pink = UIColor(red: 255/255, green: 45/255, blue: 86/255, alpha: 1.0)
    
    static let white = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    
    static let black = UIColor(red: 0.00, green: 0.0, blue: 0.0, alpha: 1.0)
    
    static let grey = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
    
    static let darkGrey = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    
    static let background_grey = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    
    
    static func random() -> UIColor{
        
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
