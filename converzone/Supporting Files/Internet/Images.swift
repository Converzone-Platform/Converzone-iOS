//
//  Images.swift
//  converzone
//
//  Created by Goga Barabadze on 25.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import UIKit
import os

extension Internet {
    
    static let image_cache = NSCache<NSString, UIImage>()
    
    private static func downloadImage(withURL url: URL, completion: @escaping (_ image:UIImage?)->()) {
        
        let data_task = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            
            var downloaded_image: UIImage?
            
            if let data = data {
                downloaded_image = UIImage(data: data)
            }
            
            guard let download_image = downloaded_image else {
                os_log("Could not cast data to UIImage")
                return
            }
            
            image_cache.setObject(download_image, forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async {
                completion(downloaded_image)
            }
            
        }
        
        data_task.resume()
    }
    
    static func getImage(withURL url: String, completion: @escaping (_ image:UIImage?)->()) {
        
        guard let url_object = URL(string: url) else{
            return
        }
        
        if let image = image_cache.object(forKey: url as NSString) {
            completion(image)
        } else {
            downloadImage(withURL: url_object, completion: completion)
        }
    }
    
}
