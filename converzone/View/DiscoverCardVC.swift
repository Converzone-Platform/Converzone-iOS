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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var design_view: UIView!
    @IBOutlet weak var handleArea_view: UIView!
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        design_view.layer.cornerRadius = 3
        design_view.layer.masksToBounds = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 1000
        
        self.view.backgroundColor = Colors.backgroundGrey
        handleArea_view.backgroundColor = Colors.backgroundGrey
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
            
        //MARK: TODO - Delete this when implementing reflections
        case 6:
            return 0
        default:
            return UITableView.automaticDimension
        }
    }
    
    fileprivate func getLocationInformation(_ cell: CountryProfileCell) {
        
        locationManager.getLocation(forPlaceCalled: profileOf!.country!.name!) { (placemark) in
            
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
                    profileOf!.timezone = placemark_zone.timeZone?.abbreviation()
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = Bundle.main.loadNibNamed("ImageProfileCell", owner: self, options: nil)?.first as! ImageProfileCell
            
            profileOf!.getImage(with: profileOf!.link_to_profile_image!, completion: { (image) in
                cell.profileImage.image = image
            })
            
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
            
            cell.sendMessage.setTitle("Send a message", for: .normal)
            cell.sendMessage.backgroundColor = Colors.blue
            cell.sendMessage.layer.cornerRadius = 10
            cell.sendMessage.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
            
            cell.sendMessage.layer.shadowColor = UIColor.black.cgColor
            cell.sendMessage.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.sendMessage.layer.shadowOpacity = 0.2
            cell.sendMessage.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 2:
            let cell = Bundle.main.loadNibNamed("GeneralProfileCell", owner: self, options: nil)?.first as! GeneralProfileCell
            
            cell.name.text = profileOf!.firstname! + " " + profileOf!.lastname!
            
            cell.speaks.numberOfLines = 0
            cell.learning.numberOfLines = 0
            
            cell.speaks.text = addLanguagesTo(level: "Speaks", languages: profileOf!.speak_languages)
            cell.learning.text = addLanguagesTo(level: "Learning", languages: profileOf!.learn_languages)
        
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
        case 3:
            let cell = Bundle.main.loadNibNamed("CountryProfileCell", owner: self, options: nil)?.first as! CountryProfileCell
            
            cell.name.text = profileOf!.country!.name
            cell.timezone.text = ""
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            if Internet.isOnline(){
                getLocationInformation(cell)
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
            
            cell.status.attributedText = profileOf!.status
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
            
            cell.interests.attributedText = profileOf!.interests
            cell.interests.setLineSpacing(lineSpacing: 3, lineHeightMultiple: 2)
            cell.interests.textAlignment = .center
            
            cell.view.layer.cornerRadius = 23
            cell.view.layer.shadowColor = UIColor.black.cgColor
            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 4.0
            
            cell.selectionStyle = .none
            
            return cell
            
//        case 6:
//
//            let cell = Bundle.main.loadNibNamed("ReflectionProfileCell", owner: self, options: nil)?.first as! ReflectionProfileCell
//
//            cell.reflection.attributedText = profileOf!.reflections.last!.text
//            cell.reflection.setLineSpacing(lineSpacing: 3, lineHeightMultiple: 2)
//            cell.reflection.textAlignment = .center
//
//            cell.writer_of_reflection.setTitle("~" + profileOf!.reflections.first!.user_name!, for: .normal)
//
//            cell.view.layer.cornerRadius = 23
//            cell.view.layer.shadowColor = UIColor.black.cgColor
//            cell.view.layer.shadowOffset = CGSize(width: 3, height: 3)
//            cell.view.layer.shadowOpacity = 0.2
//            cell.view.layer.shadowRadius = 4.0
//
//            cell.selectionStyle = .none
//
//            return cell
            
        case 7:
            let cell = Bundle.main.loadNibNamed("BlockAndReportProfileCell", owner: self, options: nil)?.first as! BlockAndReportProfileCell
            
            cell.blockAndReportOutlet.addTarget(self, action: #selector(blockandReport), for: UIControl.Event.touchUpInside)
            
            return cell
            
        default:
            print("Something bad happened while choosing the cell")
            return Bundle.main.loadNibNamed("GeneralProfileCell", owner: self, options: nil)?.first as! GeneralProfileCell
        }
        
        
    }
    
    @objc func handleSendMessage(){
    
        let info = InformationMessage()
        
        info.text = "Be creative with the first message :)"
        info.date = Date(timeIntervalSince1970: 0)
        
        profileOf?.conversation.append(info)
        
        master?.conversations.append(profileOf!)
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dViewController = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        let thirdTabNavController = self.tabBarController?.viewControllers?[0] as! UINavigationController
        
        thirdTabNavController.pushViewController(dViewController, animated: true)
        
        self.tabBarController?.selectedIndex = 0
        
    }
    
    @objc func blockandReport(){
        let alertController = UIAlertController(title: "What do you want to do?",
                                                message: "Please help us make our platform a little better. Choose 'Block' if it is something personal and 'Block and Report' if it is something that others might dislike too",
                                                preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let blockAndReport = UIAlertAction(title: "Block and Report", style: .destructive) { (action) in
            
            self.blockAndReport(title: "Report user", message: "Tell us why you want to report this user.")
        }
        alertController.addAction(blockAndReport)
        
        let block = UIAlertAction(title: "Block", style: .destructive) { (action) in
        
            Internet.databaseWithMultibleReturn(url: baseURL + "/blockAndReport.php", parameters: ["blocker_id" : master!.uid!, "blockeduser_id": profileOf!.uid!], completionHandler: { (data, response, error) in
                
                if error != nil{
                    print(error as Any)
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if !(httpResponse.statusCode == 200) {
                        
                        print(httpResponse.statusCode)
                    }
                    
                }
                
            })
            
        }
        
        alertController.addAction(block)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addLanguagesTo(level: String, languages: [Language]) -> String{
        
        if languages.count == 0{
            return ""
        }
        
        var new_label = level + ": "
        
        for i in 0...languages.endIndex-1 {
            
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
    
    func blockAndReport(title: String, message: String) {
        
        var saveTextField: UITextField? = nil
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "Send", style: .default) { (alertAction) in
            saveTextField = alert.textFields![0] as UITextField
            
            Internet.databaseWithMultibleReturn(url: baseURL + "/blockAndReport.php", parameters: ["blocker_id" : master!.uid!, "blockeduser_id": profileOf!.uid!, "reason_for_report": saveTextField!.text!], completionHandler: { (data, response, error) in
                
                if error != nil{
                    print(error as Any)
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if !(httpResponse.statusCode == 200) {
                        
                        print(httpResponse.statusCode)
                    }
                    
                }
                
            })
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Describe what's wrong"
            saveTextField = textField
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }
}
