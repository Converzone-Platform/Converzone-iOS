//
//  MessageCells.swift
//  converzone
//
//  Created by Goga Barabadze on 15.03.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import MapKit

class TextMessageCell: UITableViewCell {
    
    @IBOutlet weak var left_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var right_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var top_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottom_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var message_label: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}


class ImageMessageCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var message_imageView: UIImageView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class InformationMessageCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var information: UILabel!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class LocationMessageCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var map: MKMapView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class NeedHelpMessageCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var title_seperator: UIImageView!
    
    @IBOutlet weak var action_seperator: UIImageView!
    
    
    @IBAction func block_report(_ sender: Any) {
        
        UserProtection.displayBlockAndReport()
        
    }
    
    @IBAction func no_help(_ sender: Any) {
        
        Internet.upload(potentiallyNeedsHelp: false, user: chatOf.uid)
        
//        chatOf.conversation.removeAll(where: {$0 is NeedHelpMessage})
//
//        ChatVC().tableView.reloadData()
        
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
