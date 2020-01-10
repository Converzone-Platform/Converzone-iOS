//
//  ProfileCells.swift
//  converzone
//
//  Created by Goga Barabadze on 04.03.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import MapKit

class ImageProfileCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var profile_image: UIImageView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class SendMessageProfileCell: UITableViewCell {
    
    @IBOutlet weak var send_message: UIButton!
    
    @IBAction func send_message(_ sender: Any) {
       
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
    
    @IBOutlet weak var block_and_report: UIButton!
    
    @IBAction func block_and_report(_ sender: Any) {
        
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class InterestsProfileCell: UITableViewCell {
    
    @IBOutlet weak var interests: UILabel!
    
    @IBOutlet weak var view: UIView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class CountryProfileCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var timezone: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

class ReflectionProfileCell: UITableViewCell {
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var reflection: UILabel!
    
    @IBOutlet weak var writer_of_reflection: UIButton!
    
    @IBAction func writer_of_reflection(_ sender: Any) {
        
    }
    
    @IBAction func show_all(_ sender: Any) {
        
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
