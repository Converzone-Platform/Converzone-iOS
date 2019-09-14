//
//  StandardTextField.swift
//  converzone
//
//  Created by Goga Barabadze on 01.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

class StandardTextField: UITextField{
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        createBorder()
    }
    
    func createBorder(){
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 0.5
        self.layer.borderColor = Colors.darkGrey.cgColor
        self.borderStyle = .none
    }
    
   func isValidEmail() -> Bool {
        let emailRegEx = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text)
    }
    
    func isValidPassword() -> Bool {
        //Upper and lower Case letters
        //8 to 20 characters
        //At least One number
        let password = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,20}"
        
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", password)
        return passwordTest.evaluate(with: self.text)
    }
    
    func textFieldDidBeginEditing() {
        
        
    }
    func textFieldDidEndEditing() {
        
    }
}
