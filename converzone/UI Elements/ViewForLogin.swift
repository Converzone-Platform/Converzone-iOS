//
//  StandardView.swift
//  converzone
//
//  Created by Goga Barabadze on 03.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit

class ViewForLogin: UIView{
    
    @IBInspectable open var cornerRadius: CGFloat = 1 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
        
    }
}
