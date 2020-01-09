//
//  ReflectionDiscoverCell.swift
//  converzone
//
//  Created by Goga Barabadze on 25.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class ReflectionDiscoverCell: UITableViewCell{
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var profile_image: UIImageView!
    
    @IBOutlet weak var reflection: UILabel!
    
    @IBOutlet weak var reflection_writer: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
