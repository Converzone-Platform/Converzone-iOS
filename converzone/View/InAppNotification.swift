//
//  InAppNotification.swift
//  converzone
//
//  Created by Goga Barabadze on 25.05.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class InAppNotification: UIViewController {

    @IBOutlet weak var typeOfMessage: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        print(123)
    }
    
}
