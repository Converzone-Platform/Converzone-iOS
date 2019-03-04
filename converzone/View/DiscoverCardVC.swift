//
//  DiscoverCardVC.swift
//  converzone
//
//  Created by Goga Barabadze on 01.03.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit

class DiscoverCardVC: UIViewController {
    
    var profile_of: User!
    
    @IBOutlet weak var design: UIView!
    @IBOutlet weak var handleArea: UIView!
    
    override func viewDidLoad() {
        
        design.layer.cornerRadius = 3
        design.layer.masksToBounds = true
        
        setUpUser()
    }
    
    func setUpUser(){
        
        profile_of = User()
        
        profile_of.firstname = "Jaden"
        profile_of.lastname = "Stone"
        profile_of.country = Country(name: "France")
        profile_of.status = "No temptation has overtaken you that is not common to man. God is faithful, and he will not let you be tempted beyond your ability, but with the temptation he will also provide the way of escape, that you may be able to endure it."
        profile_of.interests = "Sport, doing stuff, doing more stuff after that and football"
        profile_of.reflections?.append(Reflection(text: "Such a nice person. you should check him out dudes", user_name: "Giorgio A.", user_id: "123", date: Date(timeIntervalSince1970: 0)))
        profile_of.reflections?.append(Reflection(text: "This is a long reflection so i can check if everything goes fine if the reflections get a little longer than planned because i like planning myself and seein my plans fail is just fun and you should try it too to be honest you might enjoy it as well", user_name: "Giorgio A.", user_id: "123", date: Date(timeIntervalSince1970: 1)))
    }
}

extension DiscoverCardVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ImageProfileCell", owner: self, options: nil)?.first as! ImageProfileCell
        
        cell.profileImage.image = UIImage(named: String(arc4random_uniform(6)))
        
        cell.profileImage.contentMode = .scaleAspectFill
        cell.profileImage.clipsToBounds = true
        cell.profileImage.layer.cornerRadius = 23
        
        cell.profileImage.layer.shadowColor = UIColor.black.cgColor
        cell.profileImage.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.profileImage.layer.shadowOpacity = 0.2
        cell.profileImage.layer.shadowRadius = 4.0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 240
        default:
            return 100
        }
        
    }
    
    
}
