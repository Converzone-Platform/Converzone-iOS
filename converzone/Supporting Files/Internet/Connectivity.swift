//
//  Connectivity.swift
//  converzone
//
//  Created by Goga Barabadze on 25.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation
import SystemConfiguration

extension Internet {
    
    static func isOnline() -> Bool {
        
        var zero_address = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zero_address.sin_len = UInt8(MemoryLayout.size(ofValue: zero_address))
        zero_address.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zero_address) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        guard let default_route_reachability = defaultRouteReachability else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(default_route_reachability, &flags) == false {
            return false
        }
        
        let is_reachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needs_connection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (is_reachable && !needs_connection)
        
        return ret
        
    }
    
}
