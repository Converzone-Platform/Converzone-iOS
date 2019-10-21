//
//  Internet.swift
//  converzone
//
//  Created by Goga Barabadze on 03.12.18.
//  Copyright © 2018 Goga Barabadze. All rights reserved.
//

import SystemConfiguration
import UIKit
import Network
import FirebaseAuth
import FirebaseDatabase

public class Internet: NSObject {
    
    // Maybe "weak" here?!
    var chat_delegate: ChatUpdateDelegate?
    var conversations_delegate: ConversationUpdateDelegate?
    
    static var ref = Database.database().reference()

    // MARK: - Connectivity
    
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
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    // MARK: Download and cache image
    
    static let imageCache = NSCache<NSString, UIImage>()
    
    private static func downloadImage(withURL url: URL, completion: @escaping (_ image:UIImage?)->()) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            var downloadedImage:UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            
            if downloadedImage != nil {
                imageCache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
            
        }
        
        dataTask.resume()
    }
    
    static func getImage(withURL url: String, completion: @escaping (_ image:UIImage?)->()) {
        if let image = imageCache.object(forKey: url as NSString) {
            completion(image)
        } else {
            downloadImage(withURL: URL(string: url)!, completion: completion)
        }
    }
    
    // MARK: - Sending messages
    static func send(message: Message, receiver: User){
        
        switch message {
        case is TextMessage: send(message: message as! TextMessage, receiver: receiver)
        default: print("Message type is not supported yet")
        }
        
    }
    
    private static func send(message: TextMessage, receiver: User){
        
        self.ref
            .child("conversations")
            .child(generateConversationID(first: master.uid!, second: receiver.uid!))
            .child(String(message.hashValue))
            
                .setValue(["sender": master.uid!,
                           "date": DateFormatter.localizedString(from: message.date!, dateStyle: .long, timeStyle: .long),
                           "text": message.text!,
                           "type": "TextMessage"])
        
    }
    
    /**
     Takes the alphabetically higher and adds the alphabetically lower id at the end
     */
    private static func generateConversationID(first: String, second: String) -> String{
        
        if first > second {
            
            return first + second
            
        }
        
        return second + first
        
    }
    
}
