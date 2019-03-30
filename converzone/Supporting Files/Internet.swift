//
//  Internet.swift
//  converzone
//
//  Created by Goga Barabadze on 03.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import SystemConfiguration
import UIKit

//Base url
var baseURL = "http://converzone.htl-perg.ac.at/"

public class Internet {
    
    class func isOnline() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    class func isConnectedToWifi() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
 
    }
    
    class func database(url: String = baseURL, parameters: [String: Any], completionHandler: @escaping (_ json: [[String: Any]]?, _ response: URLResponse?, _ error: Error?) -> ()) {
        
        var request = URLRequest(url: URL(string: url)! )
        
        request.httpMethod = "POST"
        
        //request.httpBody = par.data(using: String.Encoding.utf8)
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil{
                
                completionHandler(nil, response, error)
                
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print(json)
                guard let jsonArray = json as? [[String: Any]] else {
                    
                    completionHandler(nil, response, error)
                    
                    return
                }
                
                completionHandler(jsonArray, response, error)
                
            } catch {
                completionHandler(nil, response, error)
            }
            
        }.resume()
        
    }
    
    class func sendText(message: String){
        
    }
    
    class func sendImage(message: UIImage){
        
    }
    
    
    
}


