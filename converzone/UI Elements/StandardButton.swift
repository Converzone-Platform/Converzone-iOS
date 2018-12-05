//
//  StandardButton.swift
//  converzone
//
//  Created by Goga Barabadze on 01.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

open class StandardButton : UIButton {
    @IBInspectable open var characterSpacing: CGFloat = 1 {
        didSet {
            updateWithSpacing()
        }
        
    }
    
    open var text: String? {
        set {
            super.setTitle(newValue, for: .normal)
            updateWithSpacing()
        }
        get {
            return super.titleLabel?.text
        }
    }
    open var attributedText: NSAttributedString? {
        set {
            super.setAttributedTitle(newValue, for: .normal)
            updateWithSpacing()
        }
        get {
            return super.attributedTitle(for: .normal)
        }
    }
    func updateWithSpacing() {
        let attributedString = self.attributedText == nil ? NSMutableAttributedString(string: self.text ?? "") : NSMutableAttributedString(attributedString: attributedText!)
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: self.characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        
        super.setAttributedTitle(attributedString, for: .normal)
    }
    
    open override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: color ?? "No color"
        ]
        
        let text: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText ?? NSMutableAttributedString(string: ""))
        
        text.addAttributes(attributes, range: NSRange(location: 0, length: text.length))
        
        self.attributedText = text
    }
}


