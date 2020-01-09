//
//  StatusDiscoverCell.swift
//  converzone
//
//  Created by Goga Barabadze on 17.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class StatusDiscoverCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var view: UIView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
