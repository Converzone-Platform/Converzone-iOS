//
//  LocalNotification.swift
//  converzone
//
//  Created by Goga Barabadze on 15.12.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotification {
    
    static let notificationCenter = UNUserNotificationCenter.current()
    
    static func scheduleNotification(title: String, body: String = "", identifier: String = "ReminderNotification") {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // Configure the recurring date.
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.weekday = 6  // Tuesday
        dateComponents.hour = 15    // 14:00 hours
           
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
            print(error?.localizedDescription ?? "Error on line", #line, " in ", #function)
           }
        }
        
    }
    
}

extension Date {
    func adding(days: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = days

        return NSCalendar.current.date(byAdding: dateComponents, to: self)
    }
}
