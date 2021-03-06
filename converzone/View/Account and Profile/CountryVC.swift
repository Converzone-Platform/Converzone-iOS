//
//  CountryVC.swift
//  converzone
//
//  Created by Goga Barabadze on 08.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import UIKit
import os

class CountryVC: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var currentCountries: [Country]? = nil
    
    var filteredCountries: [Country]? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCountries = world.getCountriesOf(master.continent )
        
        filteredCountries = currentCountries
    }
    
    //Close keyboard when touched somewhere else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension CountryVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries?.count ?? 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCountryCell")
        cell?.textLabel?.text = filteredCountries![indexPath.row].name
        cell?.imageView?.image = resizeImageWithAspect(image: UIImage(named: filteredCountries![indexPath.row].flag_name)!, scaledToMaxWidth: 24.0, maxHeight: 24.0)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let country = filteredCountries?[indexPath.row] else {
            os_log("Could not extract country.")
            return
        }
        
        master.country = country
        
        if master.editingMode == .editing{
            Navigation.pop(context: self)
            Navigation.pop(context: self)
            
            Internet.upload(country: master.country)
            
        }else{
            Navigation.push(viewController: "UsersLanguagesVC", context: self)
        }
        
    }
    
    private func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height : CGFloat) -> UIImage? {
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

extension CountryVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            filteredCountries = currentCountries
            tableView.reloadData()
            return
        }
        
        filteredCountries = currentCountries?.filter({ country -> Bool in
            return country.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}
