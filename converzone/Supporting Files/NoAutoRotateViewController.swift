//
//  NoAutoRotateVC.swift
//  converzone
//
//  Created by Goga Barabadze on 14.09.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class NoAutoRotateViewController: UIViewController{
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .portrait
    }
    
}
