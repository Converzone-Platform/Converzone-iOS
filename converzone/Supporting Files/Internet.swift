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
import NotificationBannerSwift

var baseURL = "https://converzone.htl-perg.ac.at"

let manager = SocketManager(socketURL: URL(string: "wss://converzone.htl-perg.ac.at" + ":5134")!, config: [.log(true), .compress])

let socket = manager.defaultSocket

public class Internet {
    
    // Maybe "weak" here?!
    var delegate: UpdateDelegate?
    
    init() {
        
        socket.on(clientEvent: .connect) {data, ack in
            
            if master!.uid != nil{
                socket.emit("add-user", with: [["id": master?.uid]])
            }
        }

        socket.on(clientEvent: .disconnect) { (data, ack) in
            print("disconnected from server")
        }

        socket.on("chat-message") {  data, ack in

            let dic = data[0] as? [String: Any]

            let text_message = TextMessage(text: dic!["message"] as! String, is_sender: false)

            let string_date = dic!["time"] as? String
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full

            text_message.date = dateFormatter.date(from: string_date!)

            // Find a user for this message
            let user = master?.conversations.last(where: {$0.uid == dic!["sender"] as? Int})
            
            if user != nil{
                user?.conversation.append(text_message)
            }else{
                // Create a new user
                
            }
            
            
            
            self.delegate?.didUpdate(sender: self)
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
    
    class func databaseWithoutReturn(url: String = baseURL, parameters: [String: Any], completionHandler: @escaping (_ response: URLResponse?, _ error: Error?) -> ()) {
        
        var request = URLRequest(url: URL(string: url)! )
        
        request.httpMethod = "POST"
        
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil{
                
                completionHandler(response, error)
                
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if !(httpResponse.statusCode == 200) {
                    
                    print(httpResponse.statusCode)
                }
                
            }
            
        }.resume()
        
    }
    
    class func sendText(message: String, to: User){
        
        var data = [String: Any]()
        data["sender"] = master?.uid
        data["message"] = message
        data["receiver"] = to.uid
        data["deviceToken"] = to.deviceToken
        data["sound"] = "ping.aiff"
        data["senderName"] = master?.fullname
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        data["time"] = dateFormatter.string(from: NSDate() as Date)
        
        socket.emit("chat-message", data)
        
        var temp = TextMessage()
        
        temp.text = "This is text"
        
        //self.showBannerFor(message: temp)
        
    }
    
    class func showBannerFor(message: Message){
        
        // Load xib
        
        let inAppNotification = InAppNotification(nibName: "InAppNotification", bundle: nil)
        
        inAppNotification.text.text = "sdklamsd"
        
        inAppNotification.typeOfMessage.backgroundColor = message.color
        
        let banner = NotificationBanner(customView: inAppNotification.notificationView)
        banner.show(bannerPosition: .bottom)
    }
    
    class func sendImage(message: UIImage){
        
    }
}
