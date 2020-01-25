//
//  Shadows.swift
//  converzone
//
//  Created by Goga Barabadze on 22.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundCorners(radius: CGFloat, masksToBounds: Bool = false) {
        
        self.layer.masksToBounds = masksToBounds
        self.layer.cornerRadius = radius
        
    }
    
    func addShadow(radius: CGFloat = 4.0, opacity: Float = 0.2, offset: CGSize = CGSize(width: 3, height: 3), color: UIColor = .black) {
        
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        
    }
    
}
