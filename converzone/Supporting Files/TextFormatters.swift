//
//  TextFormatters.swift
//  converzone
//
//  Created by Goga Barabadze on 16.06.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import Foundation
import UIKit

class TextFormatter {
    
    class func formatAll(text: NSMutableAttributedString) -> NSMutableAttributedString{
        
        var new_text = text
        
        while(occurencies(string: new_text.string, checkFor: "!") >= 2 || occurencies(string: new_text.string, checkFor: "/") >= 2 || occurencies(string: new_text.string, checkFor: "&") >= 2 || occurencies(string: new_text.string, checkFor: "_") >= 2 || occurencies(string: new_text.string, checkFor: "-") >= 2 || occurencies(string: new_text.string, checkFor: "!") >= 2 || occurencies(string: new_text.string, checkFor: "$") >= 2){
            
            new_text = TextFormatter.formatter(text: new_text, indicator: "!", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 17)!])
            
            new_text = TextFormatter.formatter(text: new_text, indicator: "/", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Italic", size: 17)!])
            
            new_text = TextFormatter.formatter(text: new_text, indicator: "&", attributes: [NSAttributedString.Key.font : UIFont(name: "SnellRoundhand", size: 20)!])
            
            new_text = TextFormatter.formatter(text: new_text, indicator: "_", attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
            
            new_text = TextFormatter.formatter(text: new_text, indicator: "-", attributes: [NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.single.rawValue])
            
            new_text = TextFormatter.formatter(text: TextFormatter.formatCaps(text: new_text, indicator: "$"), indicator: "!", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 25)!])
            
        }
        
        return new_text
    }
    
    class func findPairsOf(formatter: Character, in text: String) -> [Any]{
        
        // Does the text even contain the formatter?
        if !text.contains(formatter) && text.count <= 1{
            return [-1, -1, ""]
        }
        
        if text.count == 2 && text[0] == text[1]{
            return [-1, -1, ""]
        }
        
        var found = false
        var text_2 = text
        
        var firstIndex = -1
        var secondIndex = -1
        
        // Search the first occurence of the formatter
        for i in 0...text.count-2{
            if text_2[i] == formatter && found == false && text_2[i+1] != " "{
                
                firstIndex = i
                
                found = true
            }
            
        }
        
        if firstIndex == -1{
            return [-1, -1, ""]
        }
        
        // Delete this found character
        text_2.remove(at: text_2.index(text_2.startIndex, offsetBy: firstIndex, limitedBy: text_2.endIndex)!)
        
        // Reset
        found = false
        
        // Search the second occurence of the formatter
        for i in 1...text.count-2{
            if text_2[i] == formatter && found == false && text_2[i-1] != " "{
                
                secondIndex = i - 1
                
                found = true
            }
            
        }
        
        if secondIndex == -1 || text_2.count == 1{
            return [-1, -1, ""]
        }
        
        // Delete this found character
        text_2.remove(at: text_2.index(text_2.startIndex, offsetBy: secondIndex + 1, limitedBy: text_2.endIndex)!)
        
        return [firstIndex, secondIndex, text_2]
    }
    
    class func formatter(text: NSMutableAttributedString, indicator: Character, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString{
        
        var str = text
        
        var indexes = findPairsOf(formatter: indicator, in: str.string)
        
        if indexes[0] as! Int == -1 || indexes[1] as! Int == -1 || indexes[2] as! String == ""{
            return str
        }
        
        str = NSMutableAttributedString(string: indexes[2] as! String)
        
        str.setAttributes(attributes, range: NSRange(location: indexes[0] as! Int, length: indexes[1] as! Int - (indexes[0] as! Int) + 1))
        
        return str
    }

    class func formatCaps(text: NSMutableAttributedString, indicator: Character) -> NSMutableAttributedString{
        var str = text
        
        var indexes = findPairsOf(formatter: indicator, in: str.string)
        
        if indexes[0] as! Int == -1 || indexes[1] as! Int == -1 || indexes[2] as! String == ""{
            return str
        }
        
        str = NSMutableAttributedString(string: indexes[2] as! String)
        
        var temp = ""
        
        for i in 0 ... str.string.count-1{
            temp += (i >= indexes[0] as! Int && i <= indexes[1] as! Int) ? str.string[i].uppercased() : String(str.string[i])
        }
        
        print(temp)
        
        return NSMutableAttributedString(string: temp)
    }
    
    class func occurencies(string: String, checkFor: Character) -> Int{
        
        var count = 0
        
        for char in string{
            if char == checkFor{
                count += 1
            }
        }
        
        return count
    }
}

