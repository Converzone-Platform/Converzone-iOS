//
//  RandomDiscoverCell.swift
//  converzone
//
//  Created by Goga Barabadze on 25.02.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class RandomDiscoverCell: UITableViewCell {
    
    @IBOutlet weak var group_outlet: UIButton!
    @IBOutlet weak var person_outlet: UIButton!
    
    @IBAction func person(_ sender: Any) {
        print("Find Random Person")
    }
    @IBAction func group(_ sender: Any) {
        print("Find Random Group")
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
