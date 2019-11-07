//
//  ContinentVC.swift
//  converzone
//
//  Created by Goga Barabadze on 06.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import MapKit
import PhoneNumberKit

var world = World(name: "Earth")

class ContinentVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let locationManager = CLLocationManager()
    
    private func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height : CGFloat)->UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    
    private func getNameOfCountry() -> String {
        let phoneNumberKit = PhoneNumberKit()
        var name: String = ""
        
        do {
            let phoneNumber = try phoneNumberKit.parse(master.phonenumber)
            let code = phoneNumber.countryCode
            let mainCountry = phoneNumberKit.mainCountry(forCode: code)
            return Country.countryName(countryCode: mainCountry!)!
        }
        catch {
            print("Generic parser error")
        }
        
        return ""
    }
    
    private func doesFlagExitst(name: String) -> Bool {
        
        if UIImage(named: getFlagNameFor(name: name)) == nil{
            return false
        }
        
        return true
    }
    
    private func getFlagNameFor(name: String) -> String {
        
        return name.replacingOccurrences(of: " ", with: "-").lowercased()
    }
}

extension ContinentVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 || section == 2 {
            return 1
        }
        
        return world.continents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocatePositionCell")
            
            cell?.textLabel?.text = NSLocalizedString("Locate my position...", comment: "Should we find out where you live?")
            
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell")
            
            cell?.textLabel?.text = world.continents[indexPath.row].name
            
            return cell!
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCountryCell")
            
            
            cell?.textLabel!.text = getNameOfCountry()
            cell?.imageView?.image = resizeImageWithAspect(image: UIImage(named: getFlagNameFor(name: getNameOfCountry()))!, scaledToMaxWidth: 24.0, maxHeight: 24.0)
            
            return cell!
            
        default:
            return tableView.dequeueReusableCell(withIdentifier: "StandardCell")!
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if doesFlagExitst(name: getNameOfCountry()) {
            return 3
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return "We could figure this out because of your phone number"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            locationManager.requestWhenInUseAuthorization()
            
            // If location services is enabled get the users location
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self as? CLLocationManagerDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }else{
                showLocationDisabledPopUp()
            }
            
            //Get Country
            geocode(latitude: locationManager.location?.coordinate.latitude ?? 2123, longitude: locationManager.location?.coordinate.longitude ?? 2123) { placemark, error in
                guard let placemark = placemark, error == nil else { return }
                
                DispatchQueue.main.async {
                    
                    //MARK: TODO - "en_US" is not suitable for all other languages than english
                    let current = Locale(identifier: "en_US")
                    let country = Country(name: current.localizedString(forRegionCode: placemark.isoCountryCode ?? "")!)
                    
                    //Ask if we got the right cuntry
                    self.askIfRightCountry(country)
                }
            }
            
            case 1:
                master.continent = world.continents[indexPath.row].name
            case 2:
                master.country = Country(name: (tableView.cellForRow(at: indexPath)?.textLabel!.text)!)
                
                if master.editingMode == .editing{
                    Navigation.pop(context: self)
                    Navigation.pop(context: self)
                    
                    Internet.upload(country: master.country)
                    
                }else{
                    Navigation.push(viewController: "UsersLanguagesVC", context: self)
                }
        default:
            print("Error: line: ", #line)
        }
        
    }
}

extension ContinentVC {
    
    private func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { completion($0?.first, $1) }
    }
    
    // If we have been deined access give the user the option to change it
    private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "In order for us to make your life simpler we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func askIfRightCountry(_ country: Country){
        let alertController = UIAlertController(title: "Your location",
                                                message: "Do you live in " + country.name! + "?",
                                                preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Yes!", style: .default) { (action) in
            master.country = country
            
            if master.editingMode == .registration {
                Navigation.push(viewController: "UsersLanguagesVC", context: self)
            }else{
                Navigation.pop(context: self)
                Internet.upload(country: master.country)
            }
        }
        
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
