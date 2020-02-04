//
//  Discover.swift
//  converzone
//
//  Created by Goga Barabadze on 25.01.20.
//  Copyright © 2020 Goga Barabadze. All rights reserved.
//

import Foundation
import os

var no_discoverable_users_left: Bool {
    return Internet.user_count-1 /*- Internet.undiscoverable_counter*/ <= fetched_count
}

extension Internet {
    
    static private func randomDiscoverStyle(for user: User){
        if Int.random(in: 0...100) >= 80 {
            user.discover_style = 1
            return
        }
    }
    
    static func findRandomUsers(){
        
        os_log("Looking for user for discover tab.")
        
        if no_discoverable_users_left {
            return
        }
        
        // Randomly select one user until we find someone we didn't have before
        let random_number_id = String(Int.random(in: 1...Internet.all_time_user_count))
        
        // Transform generated number to uid with which we can retreave the user from the database
        // E.g. "1" -> "iosdnaui29pbpqwbdabd"
        Internet.getUIDOfUser(with: random_number_id) { (uid) in
            
            // Download user from database
            Internet.getUser(with: uid) { (user) in
                
                guard let user = user else {
                    findRandomUsers()
                    return
                }
                
                
                // We shouldn't show ourselves in the discover tab
                if master.uid == user.uid {
                    findRandomUsers()
                    return
                }
                
                // Do we have this user already?
                if discover_users.contains(user) {
                    findRandomUsers()
                    return
                }
                
                // Does the user not want to be discovered?
                if user.discoverable == false {
                    findRandomUsers()
                    fetched_count += 1
                    return
                }
                
                // Have we blocked this user?
                if master.blocked_users.contains(user.uid) {
                    findRandomUsers()
                    fetched_count += 1
                    return
                }
                
                // Does the age meet our filter criteria?
                if user.age < master.discover_min_filter_age || user.age > master.discover_max_filter_age {
                    findRandomUsers()
                    fetched_count += 1
                    return
                }
                
                // Do we meet their age filter criteria?
                if master.age < user.discover_min_filter_age || user.age > user.discover_max_filter_age {
                    findRandomUsers()
                    fetched_count += 1
                    return
                }
                
                // Does the gender meet our filter criteria?
                if !(master.discover_gender_filter == .any || user.gender == master.discover_gender_filter || user.gender == .unknown) {
                    findRandomUsers()
                    fetched_count += 1
                    return
                }
                
                // Do we meet their gender filter criteria?
                if !(user.discover_gender_filter == .any || master.gender == user.discover_gender_filter || master.gender == .unknown) {
                    findRandomUsers()
                    fetched_count += 1
                    return
                }
                
                // Passed all test
                randomDiscoverStyle(for: user)
                discover_users.append(user)
                
                fetched_count += 1
                
                Internet.update_discovery_tableview_delegate?.didUpdate(sender: Internet())
            }
        }
        
    }
}
