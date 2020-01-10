//
//  ChatCell.swift
//  converzone
//
//  Created by Goga Barabadze on 28.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var profile_image: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var last_message_type: UIImageView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
