//
//  StandardLabel.swift
//  converzone
//
//  Created by Goga Barabadze on 01.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//
import UIKit

open class LabelForLogin : UILabel {
    @IBInspectable open var characterSpacing:CGFloat = 1 {
        didSet {
            updateWithSpacing()
        }
        
    }
    
    open override var text: String? {
        set {
            super.text = newValue
            updateWithSpacing()
        }
        get {
            return super.text
        }
    }
    open override var attributedText: NSAttributedString? {
        set {
            super.attributedText = newValue
            updateWithSpacing()
        }
        get {
            return super.attributedText
        }
    }
    
    func updateWithSpacing() {
        let attributedString = self.attributedText == nil ? NSMutableAttributedString(string: self.text ?? "") : NSMutableAttributedString(attributedString: attributedText!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: self.characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        super.attributedText = attributedString
    }
}

