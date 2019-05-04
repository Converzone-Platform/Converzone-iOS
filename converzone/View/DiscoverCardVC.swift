//
//  DiscoverCardVC.swift
//  converzone
//
//  Created by Goga Barabadze on 01.03.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import UIKit
import MapKit

class DiscoverCardVC: UIViewController {
    
    var profile_of: User!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var design_view: UIView!
    @IBOutlet weak var handleArea_view: UIView!
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        design_view.layer.cornerRadius = 3
        design_view.layer.masksToBounds = true
        
        setUpUser()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 1000
        
        self.view.backgroundColor = Colors.backgroundGrey
        handleArea_view.backgroundColor = Colors.backgroundGrey
    }
    
    func setUpUser(){
        
        profile_of = User()
        
        profile_of.firstname = "Jaden"
        profile_of.lastname = "Stone"
        profile_of.country = Country(name: "France")
        profile_of.country?.flag_name = "france"
        profile_of.status = NSAttributedString(string: "No temptation has overtaken you that is not common to man. God is faithful, and he will not let you be tempted beyond your ability, but with the temptation he will also provide the way of escape, that you may be able to endure it.No temptation has overtaken you that is not common to man. God is faithful, and he will not let you be tempted beyond your ability, but with the temptation he will also provide the way of escape, that you may be able to endure it.")
        profile_of.interests = NSAttributedString(string: "Hobbies provide many mental and physical health benefits, including bolstered optimism, increased creativity and a better ability to deal with stress. Sharing hobbies with others also keeps teens socially engaged with people who have similar interests. The type of hobby a teen is interested in is limited only by the imagination of the person.")
        
        profile_of.reflections.append(Reflection(text: NSAttributedString(string: "You are more fun than anyone or anything I know, including bubble wrap."), user_name: "Anya Knack", user_id: "123", date: Date(timeIntervalSince1970: 0)))
        
        profile_of.reflections.append(Reflection(text: NSAttributedString(string: "You make me float up like I’m on millions of bubbles (We got this one from one of our kids after he got a new coat.)"), user_name: "Shaneka Ostby", user_id: "312", date: Date(timeIntervalSince1970: 0)))
        
        profile_of.reflections.append(Reflection(text: NSAttributedString(string: "You are a great parent. You can tell just by looking at how thoughtful your kids are (A two-for-one compliment)"), user_name: "Clair Grosvenor", user_id: "1231", date: Date(timeIntervalSince1970: 0)))
        
        profile_of.reflections.append(Reflection(text: NSAttributedString(string: "I know that you will always have my back, because that is the kind of person you are."), user_name: "Rayna Healy", user_id: "123123", date: Date(timeIntervalSince1970: 0)))
        
        profile_of.learn_languages = [Language(name: "German"), Language(name: "Spanish")]
        profile_of.speak_languages = [Language(name: "French"), Language(name: "English"), Language(name: "Swedish")]
    }
}

extension DiscoverCardVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return self.view.frame.height / 2
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = Bundle.main.loadNibNamed("ImageProfileCell", owner: self, options: nil)?.first as! ImageProfileCell
            
            cell.profileImage.image = UIImage(named: String(arc4random_uniform(14)))
            
            cell.profileImage.contentMode = .scaleAspectFill
            cell.profileImage.clipsToBounds = true
            cell.profileImage.layer.cornerRadius = 23
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
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
            
//            cell.country.text = profile_of.country?.name
//            cell.flag.image = UIImage(named: (profile_of.country?.flag_name)!)
            cell.name.text = profile_of.firstname! + " " + profile_of.lastname!
            cell.speaks.text = addLanguagesTo(level: "Speaks", languages: profile_of.speak_languages)
            cell.learning.text = addLanguagesTo(level: "Learning", languages: profile_of.learn_languages)
        
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 3:
            let cell = Bundle.main.loadNibNamed("CountryProfileCell", owner: self, options: nil)?.first as! CountryProfileCell
            
            cell.name.text = profile_of.country!.name
            cell.timezone.text = ""
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            if Internet.isOnline(){
                locationManager.getLocation(forPlaceCalled: profile_of!.country!.name!) { (placemark) in

                    cell.map.mapType = .standard

                    let latDelta:CLLocationDegrees = 180
                    let lonDelta:CLLocationDegrees = 180

                    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                    let location = CLLocationCoordinate2DMake((placemark?.coordinate.latitude)!, (placemark?.coordinate.longitude)!)
                    let region = MKCoordinateRegion(center: location, span: span)

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = (placemark?.coordinate)!

                    cell.map.addAnnotation(annotation)
                    cell.map.setRegion(region, animated: false)
                    cell.map.setCenter((placemark?.coordinate)!, animated: true)

                    // Time Zone
                    let geoCoder = CLGeocoder()
                    geoCoder.reverseGeocodeLocation(placemark!) { (placemarks, err) in
                        if let placemark_zone = placemarks?[0] {

                            cell.timezone.text = placemark_zone.timeZone?.abbreviation()
                            self.profile_of.timezone = placemark_zone.timeZone?.abbreviation()
                        }
                    }

                }
            }
            
            cell.map.layer.cornerRadius = 23
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 4:
            let cell = Bundle.main.loadNibNamed("StatusProfileCell", owner: self, options: nil)?.first as! StatusProfileCell
            
            cell.status.attributedText = profile_of.status
            cell.status.setLineSpacing(lineSpacing: 3, lineHeightMultiple: 2)
            cell.status.textAlignment = .center
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 5:
            let cell = Bundle.main.loadNibNamed("InterestsProfileCell", owner: self, options: nil)?.first as! InterestsProfileCell
            
            cell.interests.attributedText = profile_of.interests
            cell.interests.setLineSpacing(lineSpacing: 3, lineHeightMultiple: 2)
            cell.interests.textAlignment = .center
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 6:
            
            let cell = Bundle.main.loadNibNamed("ReflectionProfileCell", owner: self, options: nil)?.first as! ReflectionProfileCell
            
            cell.reflection.attributedText = profile_of.reflections.last!.text
            cell.reflection.setLineSpacing(lineSpacing: 3, lineHeightMultiple: 2)
            cell.reflection.textAlignment = .center
            
            cell.writer_of_reflection.setTitle("~" + profile_of.reflections.first!.user_name!, for: .normal)
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 7:
            let cell = Bundle.main.loadNibNamed("BlockAndReportProfileCell", owner: self, options: nil)?.first as! BlockAndReportProfileCell
            
            
            return cell
            
        default:
            print("Something bad happened while choosing the cell")
            return Bundle.main.loadNibNamed("GeneralProfileCell", owner: self, options: nil)?.first as! GeneralProfileCell
        }
        
        
    }
    
    func addLanguagesTo(level: String, languages: [Language]) -> String{
        
        var new_label = level + ": "
        
        for i in 0...languages.endIndex-1{
            
            if i == languages.endIndex-1 && languages.count > 1{
                new_label += " & "
            }else{
                if i != 0{
                    new_label += ", "
                }
            }
            
            new_label += languages[i].name
        }
        
        return new_label
    }
}
