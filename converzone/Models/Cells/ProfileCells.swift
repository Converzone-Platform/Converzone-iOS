//
//  ProfileCells.swift
//  converzone
//
//  Created by Goga Barabadze on 04.03.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class ImageProfileCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class SendMessageProfileCell: UITableViewCell {
    
    @IBOutlet weak var sendMessage: UIButton!
    
    @IBAction func sendMessage(_ sender: Any) {
        print("Send message")
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class GeneralProfileCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var speaks: UILabel!
    @IBOutlet weak var learning: UILabel!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var view: UIView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class StatusProfileCell: UITableViewCell {
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var view: UIView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}


class BlockAndReportProfileCell: UITableViewCell {
    
    
    @IBAction func blockAndReport(_ sender: Any) {
        
        print("Block and Report")
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
