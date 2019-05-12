//
//  Internet.swift
//  converzone
//
//  Created by Goga Barabadze on 03.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import SystemConfiguration
import UIKit
import SocketIO

var baseURL = "http://converzone.htl-perg.ac.at"

let manager = SocketManager(socketURL: URL(string: baseURL + ":3000")!, config: [.log(true), .compress])
let socket = manager.defaultSocket

var temp = [TextMessage]()

public class Internet {
    
    init() {
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print("disconnected from server")
        }
        
        socket.on("message") { (data, ack) in
            
            let dic = data[0] as? [String: Any]
            
            let text_message = TextMessage(text: dic!["message"] as! String, is_sender: false)
            
            let string_date = dic!["time"] as? String
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            
            text_message.date = dateFormatter.date(from: string_date!)
            
            
            print(text_message.text)
            //master?.conversations.first?.conversation.append(text_message)
            //ChatVC().updateTableView(animated: true)
        }
        
        socket.connect()
    }
    
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
    
    class func database(url: String = baseURL, parameters: [String: Any], completionHandler: @escaping (_ json: [String: Any]?, _ response: URLResponse?, _ error: Error?) -> ()) {
        
        var request = URLRequest(url: URL(string: url)! )
        
        request.httpMethod = "POST"
        
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil{
                
                completionHandler(nil, response, error)
                
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                
                guard let jsonArray = json as? [String: Any] else {
                    
                    completionHandler(nil, response, error)
                    
                    return
                }
                
                completionHandler(jsonArray, response, error)
                
            } catch {
                completionHandler(nil, response, error)
            }
            
        }.resume()
        
    }
    
    class func databaseWithMultibleReturn(url: String = baseURL, parameters: [String: Any], completionHandler: @escaping (_ json: [[String: Any]]?, _ response: URLResponse?, _ error: Error?) -> ()) {
        
        var request = URLRequest(url: URL(string: url)! )
        
        request.httpMethod = "POST"
        
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil{
                
                completionHandler(nil, response, error)
                
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                
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
        
        var data = [String: Any]()
        data["uid"] = master?.uid
        data["message"] = message
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        data["time"] = dateFormatter.string(from: NSDate() as Date)
        
        socket.emit("message", data)
        
    }
    
    func handleMessage(jsonString:String){
        if let data = jsonString.data(using: String.Encoding.utf8){
            do {
                let JSON = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                print("We've successfully parsed the message into a Dictionary! Yay!\n\(JSON)")
            } catch let error{
                print("Error parsing json: \(error)")
            }
        }
    }
    
    class func sendImage(message: UIImage){
        
    }
}
