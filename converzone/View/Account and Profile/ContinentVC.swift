//
//  ContinentVC.swift
//  converzone
//
//  Created by Goga Barabadze on 06.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import MapKit
import os

var world = World(name: "Earth")

class ContinentVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let location_manager = CLLocationManager()
    
    
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
            
            cell?.imageView?.image = UIImage(systemName: "location.fill")
            
            cell?.textLabel?.text = NSLocalizedString("Locate my position...", comment: "Should we find out where you live?")
            
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell")
            
            cell?.textLabel?.text = world.continents[indexPath.row].name
            
            return cell!
        default:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
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
            location_manager.requestWhenInUseAuthorization()
            
            // If location services is enabled get the users location
            if CLLocationManager.locationServicesEnabled() {
                location_manager.delegate = self as? CLLocationManagerDelegate
                location_manager.desiredAccuracy = kCLLocationAccuracyBest
                location_manager.startUpdatingLocation()
            }else{
                showLocationDisabledPopUp()
            }
            
            //Get Country
            geocode(latitude: location_manager.location?.coordinate.latitude ?? 2123, longitude: location_manager.location?.coordinate.longitude ?? 2123) { placemark, error in
                guard let placemark = placemark, error == nil else { return }
                
                DispatchQueue.main.async {
                    
                    let current = Locale(identifier: "en_US")
                    
                    guard let name = current.localizedString(forRegionCode: placemark.isoCountryCode ?? "") else {
                        return
                    }
                    
                    let country = Country(name: name)
                    
                    //Ask if we got the right cuntry
                    self.askIfRightCountry(country)
                }
            }
            
            case 1:
                master.continent = world.continents[indexPath.row].name
            case 2:
                
                guard let name = tableView.cellForRow(at: indexPath)?.textLabel?.text else {
                    os_log("Could not extract name.")
                    return
                }
                
                master.country = Country(name: name)
                
                if master.editingMode == .editing{
                    Navigation.pop(context: self)
                    Navigation.pop(context: self)
                    
                    Internet.upload(country: master.country)
                    
                }else{
                    Navigation.push(viewController: "UsersLanguagesVC", context: self)
                }
        default:
            fatalError()
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
        
        let actions = [
        
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil),
            
            UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
        ]
        
        Alert.alert(title: "Location Access Disabled", message: "In order for us to make your life simpler we need your location", actions: actions)
    }
    
    private func askIfRightCountry(_ country: Country){
        
        let actions = [
        
            UIAlertAction(title: "No", style: .cancel, handler: nil),
            
            UIAlertAction(title: "Yes!", style: .default) { (action) in
                master.country = country
                
                if master.editingMode == .registration {
                    Navigation.push(viewController: "UsersLanguagesVC", context: self)
                }else{
                    Navigation.pop(context: self)
                    Internet.upload(country: master.country)
                }
            }
            
        ]
        
        Alert.alert(title: "Your location", message: "Do you live in " + country.name + "?", actions: actions)
    }
    
}
