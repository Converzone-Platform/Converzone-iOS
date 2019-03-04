//
//  ProfileCells.swift
//  converzone
//
//  Created by Goga Barabadze on 04.03.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class ImageProfileCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
