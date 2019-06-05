//
//  Person.swift
//  converzone
//
//  Created by Goga Barabadze on 04.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

/* This is a standard class for everyone who is a Person
    The main user and all other users will extend this class later */

import Foundation
import MapKit

class Person {
    
    //Personal Details
    internal var firstname: String? = ""
    internal var lastname: String? = ""
    
    internal var fullname: String?{
        return firstname! + " " + lastname!
    }
    
    internal var gender: Gender?
    internal var birthdate: Date?
    internal var main_language: Language?
    internal var speak_languages: [Language] = []
    internal var learn_languages: [Language] = []
    
    internal var continent: String?
    internal var country: Country?
    internal var coordinate: CLLocationCoordinate2D?
    internal var timezone: String?
    
    //Platform Informations
    internal var interests: NSAttributedString?
    internal var status: NSAttributedString?
    
    internal let cache = NSCache<NSString, UIImage>()
    internal var link_to_profile_image: String?
    
    internal var reflections: [Reflection] = []
    internal var uid: Int?
    
    internal var deviceToken: String?
    
    init (firstname: String, lastname: String, gender: Gender, birthdate: Date, uid: Int){
        self.firstname = firstname
        self.lastname = lastname
        self.gender = gender
        self.birthdate = birthdate
        self.uid = uid
    }
    
    init(){
        
    }
    
    //Functionality
    func sortLanguagesAlphabetically(){
        
        self.speak_languages.sort{
            $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
        }
        
        self.learn_languages.sort{
            $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
        }
        
    }
    
    
    private func downloadImage(with url: String, completion: @escaping (_ image: UIImage?)->()){
        
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            
            var downloadedImage: UIImage?
            
            if let data = data{
                downloadedImage = UIImage(data: data)
            }
            
            if downloadedImage != nil {
                self.cache.setObject(downloadedImage!, forKey: url as NSString)
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
            
        }.resume()
        
    }
    
    func getImage(with url: String, completion: @escaping (_ image: UIImage?)->()){
        
        if let image = cache.object(forKey: url as NSString){
            completion(image)
        }else{
            downloadImage(with: url, completion: completion)
        }
        
    }
}
