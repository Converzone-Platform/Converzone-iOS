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
            
            let banner = StatusBarNotificationBanner(title: "", style: .success, colors: nil)
            banner.bannerHeight = 10
            banner.show()
        }

        socket.on(clientEvent: .disconnect) { (data, ack) in
            let banner = StatusBarNotificationBanner(title: "", style: .danger, colors: nil)
            banner.bannerHeight = 10
            banner.show()
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
                user?.openedChat = false
            }else{
                
//                // Create a new user
//                
//                let temp_dic = Internet.getInformationAboutUserWith(id: (dic!["sender"] as? Int)!)
//                
//                let new_user = User()
//                //new_user.firstname =
//                
//                new_user.openedChat = false
//                master?.conversations.append(new_user)
                
            }
            
            self.displayNotificationBanner(sender: "Sender", typeOfMessage: text_message.color!, profilePictureURL: (user?.link_to_profile_image!)!)
            
            self.delegate?.didUpdate(sender: self)
        }

        socket.connect()
    }
    
    func displayNotificationBanner(sender: String, typeOfMessage: UIColor, profilePictureURL: String){
        
        let notificationView = UINib(nibName: "InAppNotification", bundle: nil).instantiate(withOwner: self, options: nil).first as! InAppNotification
        
        notificationView.notification.layer.masksToBounds = true
        notificationView.notification.layer.cornerRadius = 14
        
        notificationView.notification.layer.shadowColor = UIColor.black.cgColor
        notificationView.notification.layer.shadowOffset = CGSize(width: 3, height: 3)
        notificationView.notification.layer.shadowOpacity = 0.7
        notificationView.notification.layer.shadowRadius = 10
        
        notificationView.profileImage.image = resizeImageWithAspect(image: UIImage(named: "11")!, scaledToMaxWidth: 37, maxHeight: 37)
        notificationView.profileImage.layer.masksToBounds = true
        notificationView.profileImage.layer.cornerRadius = 37 / 2
        
        notificationView.message.text = sender
        notificationView.message.textColor = Colors.black
        
        notificationView.typeOfMessage.backgroundColor = typeOfMessage
        notificationView.typeOfMessage.layer.masksToBounds = true
        notificationView.typeOfMessage.layer.cornerRadius = 2
        
        let banner = NotificationBanner(customView: notificationView.notification)
        banner.show()
    }
    
    func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
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
    
    class func getInformationAboutUserWith(id: Int) -> [String: Any]{

        var temp_data: [String: Any]? = nil
        
        Internet.database(url: baseURL + "/getInformationOfUser.php", parameters: ["id": id]) { (data, response, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            //Did the server give back an error?
            if let httpResponse = response as? HTTPURLResponse {
                
                if !(httpResponse.statusCode == 200) {
                    
                    fatalError("error on line: \(#line)")
                    
                }
            }
            
            temp_data = data
            
        }
        
        return temp_data!
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
            
            if error != nil {
                
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
        
        //Internet.getInformationAboutUserWith(id: 1)
        
    }
    
    class func showBannerFor(message: Message){
        
        // Load xib
        
        //let inAppNotification = InAppNotification(nibName: "InAppNotification", bundle: nil)
        
        //inAppNotification.text.text = "sdklamsd"
        
        //inAppNotification.typeOfMessage.backgroundColor = message.color
        
        //let banner = NotificationBanner(customView: inAppNotification.notificationView)
        
//        let banner = NotificationBanner(title: message., subtitle: "", style: .success)
//
//        banner.show(bannerPosition: .bottom)
    }
    
    class func sendImage(message: UIImage){
        
    }
}
