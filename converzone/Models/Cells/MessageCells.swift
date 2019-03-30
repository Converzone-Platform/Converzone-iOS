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
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
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
