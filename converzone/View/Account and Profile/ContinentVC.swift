//
//  ContinentVC.swift
//  converzone
//
//  Created by Goga Barabadze on 06.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import MapKit

var world = World(name: "Earth")

class ContinentVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let locationManager = CLLocationManager()
    
    fileprivate func goBack() {
        //Go back to login view controller
        Navigation.present(controller: "LoginVC", context: self)
    }
    
    @IBAction func back(_ sender: Any) {
        goBack()
    }
    
}

extension ContinentVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0){
            return 1
        }
        
        return world.continents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocatePositionCell")
            
            cell?.textLabel?.text = NSLocalizedString("Locate my position...", comment: "Should we find out where you live?")
            
            return cell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell")
        
        cell?.textLabel?.text = world.continents[indexPath.row].name
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Does the person want us to check the position by ourselves?
        if(indexPath.section == 0){
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
                    
                    //MARK: - TODO "en_US" is not suitable for all other languages than english
                    let current = Locale(identifier: "en_US")
                    let country = Country(name: current.localizedString(forRegionCode: placemark.isoCountryCode ?? "")!)
                    
                    //Ask if we got the right cuntry
                    self.askIfRightCountry(country)
                }
            }
            
        }else{
            
            master?.continent = world.continents[indexPath.row].name
        }
    }
}

extension ContinentVC {
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { completion($0?.first, $1) }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
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
    
    func askIfRightCountry(_ country: Country){
        let alertController = UIAlertController(title: "Your location",
                                                message: "Do you live in " + country.name! + "?",
                                                preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Yes!", style: .default) { (action) in
            master?.country = country
            
            //Go to next view controller
            Navigation.push(viewController: "UsersLanguagesVC", context: self)
        }
        
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
