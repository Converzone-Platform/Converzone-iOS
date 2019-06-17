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
import NotificationCenter
import Network

var baseURL = "https://converzone.htl-perg.ac.at"

let manager = SocketManager(socketURL: URL(string: "wss://converzone.htl-perg.ac.at" + ":5134")!, config: [.log(true), .compress])

let socket = manager.defaultSocket

public class Internet: NSObject {
    
    // Maybe "weak" here?!
    var delegate: UpdateDelegate?
    
    override init() {
        
        super.init()
        
        socket.on(clientEvent: .connect) {data, ack in
            
            if master!.uid != nil && master!.addedUserSinceLastConnect == false{
                socket.emit("add-user", with: [["id": master?.uid]])
                master?.addedUserSinceLastConnect = true
                
                let banner = StatusBarNotificationBanner(title: "", style: .success, colors: nil)
                banner.bannerHeight = 10
                banner.show()
            }
        }

        socket.on(clientEvent: .disconnect) { (data, ack) in
            
            let banner = StatusBarNotificationBanner(title: "", style: .danger, colors: nil)
            banner.bannerHeight = 10
            banner.show()
            
            master?.addedUserSinceLastConnect = false
            
        }

        socket.on("chat-message") {  data, ack in

            let dic = data[0] as? [String: Any]

            let text_message = TextMessage(text: NSMutableAttributedString(string: dic!["message"] as! String), is_sender: false)

            let string_date = dic!["time"] as? String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss:SSSXXXXX"

            text_message.date = dateFormatter.date(from: string_date!)

            // Find a user for this message
            let user = master?.conversations.last(where: {$0.uid == dic!["sender"] as? Int})
            
            if user != nil{
                
                // Make duplicates disappear
                let temp = user?.conversation.count
                user?.conversation.removeAll(where: { (message) -> Bool in
                    return message.hashValue == text_message.hashValue
                })
                
                if temp == user?.conversation.count{
                    if !(indexOfUser == user!.uid) {
                        self.displayNotificationBanner(sender: (user?.fullname)!, typeOfMessage: text_message.color!, profilePictureURL: user!.link_to_profile_image!)
                    }
                }
                
                user?.conversation.append(text_message)
                user?.openedChat = true
                
                self.delegate?.didUpdate(sender: self)
            }else{
                
//                // Create a new user
                Internet.databaseWithMultibleReturn(url: baseURL + "/getInformationOfUser.php",parameters: ["id": dic!["sender"] as! Int], completionHandler: { (user_data, response, error) in
                    
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    //Did the server give back an error?
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        if !(httpResponse.statusCode == 200) {
                            
                            print(httpResponse.statusCode)
                            
                        }
                    }
                    
                    let new_user_data = user_data![0]
                    
                    user?.firstname = new_user_data["FIRSTNAME"] as? String
                    user?.lastname = new_user_data["LASTNAME"] as? String
                    user?.uid = Int((new_user_data["USERID"] as? String)!)
                    user?.gender = self.genderConverter(gender: (new_user_data["GENDER"] as? String)!)
                    user?.status = NSAttributedString(string: (new_user_data["STATUS"] as? String)!)
                    user?.interests = NSAttributedString(string: (new_user_data["INTERESTS"] as? String)!)
                    user?.country = Country(name: (new_user_data["COUNTRY"] as? String)!)
                    user?.deviceToken = new_user_data["NOTIFICATIONTOKEN"] as? String
                    user?.link_to_profile_image = new_user_data["PROFILE_PICTURE_URL"] as? String
                    
                    let string_date = new_user_data["BIRTHDATE"] as? String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
                    user?.birthdate = dateFormatter.date(from: string_date!)
                    
                    
                    Internet.databaseWithMultibleReturn(url: baseURL + "/languages.php", parameters: ["id": user?.uid as! Int], completionHandler: { (languages, response, error) in
                        
                        if let httpResponse = response as? HTTPURLResponse {
                            
                            if !(httpResponse.statusCode == 200) {
                                
                                print(httpResponse.statusCode)
                            }
                            
                        }
                        
                        if languages != nil {
                            
                            for language in languages!{
                                
                                let languageToAdd = Language(name: (language["LANGUAGE"] as? String)!)
                                
                                if language["PROFICIENCY"] as? String == "l"{
                                    user!.learn_languages.append(languageToAdd)
                                }else{
                                    user!.speak_languages.append(languageToAdd)
                                }
                                
                            }
                        }
                        
                    })
                    
                    user!.openedChat = true
                    master?.conversations.append(user!)
                    
                    //self.displayNotificationBanner(sender: (user?.fullname)!, typeOfMessage: text_message.color!, profilePictureURL: user!.link_to_profile_image!)
                    
                    self.delegate?.didUpdate(sender: self)
                })
                
                
                //user.firstname =
                
                
            }
        }

        socket.connect()
    }
    
    func genderConverter(gender: String) -> Gender{
        switch gender {
        case "f":
            return Gender.female
        case "m":
            return Gender.male
        case "n":
            return Gender.non_binary
        default:
            return Gender.non_binary
        }
    }
    
    func displayNotificationBanner(sender: String, typeOfMessage: UIColor, profilePictureURL: String){
        
        let notificationView = UINib(nibName: "InAppNotification", bundle: nil).instantiate(withOwner: self, options: nil).first as! InAppNotification
        
        notificationView.notification.layer.masksToBounds = true
        notificationView.notification.layer.cornerRadius = 14
        
        notificationView.notification.layer.shadowColor = UIColor.black.cgColor
        notificationView.notification.layer.shadowOffset = CGSize(width: 3, height: 3)
        notificationView.notification.layer.shadowOpacity = 0.7
        notificationView.notification.layer.shadowRadius = 10
        
        master?.getImage(with: profilePictureURL, completion: { (image) in
            notificationView.profileImage.image = self.resizeImageWithAspect(image: image!, scaledToMaxWidth: 37, maxHeight: 37)
            notificationView.profileImage.layer.masksToBounds = true
            notificationView.profileImage.layer.cornerRadius = 37 / 2
        })
        
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
        data["type"] = ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss:SSSXXXXX"
        data["time"] = dateFormatter.string(from: NSDate() as Date)

        socket.emit("chat-message", data)
        
    }
    
    class func sendImage(message: UIImage){
        
    }
}
