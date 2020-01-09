//
//  DateEngine.swift
//  converzone
//
//  Created by Goga Barabadze on 22.10.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import Foundation
import os

extension Date {
    
    enum Style {
        
        
        case dayMonthYear
        
        case dayMonthYearHourMinute
        
        case dayMonthYearHourMinuteSecondMillisecondTimezone
        
    }
    
    static func dateAsString(style: Date.Style, date: Date) -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = fromStyleToString(style: style)

        return formatter.string(from: date)
        
    }
    
    static func currentDateAsString(style: Date.Style) -> String {
        
        return dateAsString(style: style, date: Date())
        
    }
    
    private static func fromStyleToString(style: Date.Style) -> String{
        
        switch style {
            
        case .dayMonthYear: return "dd.MM.yyyy"
            
        case .dayMonthYearHourMinute: return "dd.MM.yyyy HH:mm"
            
        case .dayMonthYearHourMinuteSecondMillisecondTimezone: return "dd.MM.yyyy HH:mm:ss:SSS Z"
            
        }
        
    }
    
    static func stringAsDate(style: Date.Style, string: String) -> Date{
        
        let formatter = DateFormatter()
        formatter.dateFormat = fromStyleToString(style: style)
        
        guard let date = formatter.date(from: string) else {
            os_log("Could not extract date from DateFormatter.")
            return Date()
        }
        
        return date
        
    }
    
    static func dateAsTimeIntervalSince1970WithoutDots(date: Date) -> String {
        
        let rounded = round(1000 * date.timeIntervalSince1970) / 1000
        return String(rounded).replacingOccurrences(of: ".", with: "")
    }
    
    private static func yearsSince(date: Date) -> Int {
        
        let now = Date()
        let calendar = Calendar.current

        let ageComponents = calendar.dateComponents([.year], from: date, to: now)
        
        return ageComponents.year!
    }
    
}
