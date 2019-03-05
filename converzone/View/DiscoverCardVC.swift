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
        profile_of.country?.flag_name = "france"
        profile_of.status = "No temptation has overtaken you that is not common to man. God is faithful, and he will not let you be tempted beyond your ability, but with the temptation he will also provide the way of escape, that you may be able to endure it."
        profile_of.interests = "Sport, doing stuff, doing more stuff after that and football"
        profile_of.reflections?.append(Reflection(text: "Such a nice person. you should check him out dudes", user_name: "Giorgio A.", user_id: "123", date: Date(timeIntervalSince1970: 0)))
        profile_of.reflections?.append(Reflection(text: "This is a long reflection so i can check if everything goes fine if the reflections get a little longer than planned because i like planning myself and seein my plans fail is just fun and you should try it too to be honest you might enjoy it as well", user_name: "Giorgio A.", user_id: "123", date: Date(timeIntervalSince1970: 1)))
        profile_of.learn_languages = [Language(name: "German"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish"), Language(name: "Spanish")]
        profile_of.speak_languages = [Language(name: "French"), Language(name: "English")]
    }
}

extension DiscoverCardVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = Bundle.main.loadNibNamed("ImageProfileCell", owner: self, options: nil)?.first as! ImageProfileCell
            
            cell.profileImage.image = UIImage(named: String(arc4random_uniform(6)))
            
            cell.profileImage.contentMode = .scaleAspectFill
            cell.profileImage.clipsToBounds = true
            cell.profileImage.layer.cornerRadius = 23
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            return cell
        case 1:
            let cell = Bundle.main.loadNibNamed("SendMessageProfileCell", owner: self, options: nil)?.first as! SendMessageProfileCell
            
            cell.sendMessage.setTitle("Bonjour", for: .normal)
            cell.sendMessage.backgroundColor = Colors.blue
            cell.sendMessage.layer.cornerRadius = 10
            
            cell.sendMessage.layer.shadowColor = UIColor.black.cgColor
            cell.sendMessage.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.sendMessage.layer.shadowOpacity = 0.2
            cell.sendMessage.layer.shadowRadius = 4.0
            
            return cell
            
        case 2:
            let cell = Bundle.main.loadNibNamed("GeneralProfileCell", owner: self, options: nil)?.first as! GeneralProfileCell
            
            cell.country.text = profile_of.country?.name
            cell.flag.image = UIImage(named: (profile_of.country?.flag_name)!)
            cell.name.text = profile_of.firstname! + " " + profile_of.lastname!
            cell.speaks.text = addLanguagesTo(level: "Speaks", languages: profile_of.speak_languages!)
            cell.learning.text = addLanguagesTo(level: "Learning", languages: profile_of.learn_languages!)
        
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            return cell
            
        case 3:
            let cell = Bundle.main.loadNibNamed("StatusProfileCell", owner: self, options: nil)?.first as! StatusProfileCell
            
            cell.status.text = profile_of.status
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            return cell
            
        case 6:
            let cell = Bundle.main.loadNibNamed("BlockAndReportProfileCell", owner: self, options: nil)?.first as! BlockAndReportProfileCell
            
            
            return cell
            
        default:
                print("Something bad happened while choosing the cell")
        }
        
        return Bundle.main.loadNibNamed("SendMessageProfileCell", owner: self, options: nil)?.first as! SendMessageProfileCell
    }
    
    func addLanguagesTo(level: String, languages: [Language]) -> String{
        
        var new_label = level + ": "
        
        for language in languages {
            
            new_label += ", " + language.name!
            
        }
        
        return new_label
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 300
        case 1:
            return 45
        case 2:
            return 270
        case 3:
            
            let cell = Bundle.main.loadNibNamed("StatusProfileCell", owner: self, options: nil)?.first as! StatusProfileCell
            
            
            print(profile_of.status?.height(withWidth: 309, font:UIFont(name: "Helvetica Neue", size: 14)!))
            
            //return (cell.status.text?.height(withWidth: 309, font: UIFont(name: "Helvetica Neue", size: 14)!))!
            
            return 300
            
        case 6:
            return 30
            
        default:
            return 100
        }
        
    }
    
    
}
