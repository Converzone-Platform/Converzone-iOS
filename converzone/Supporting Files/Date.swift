//
//  DateEngine.swift
//  converzone
//
//  Created by Goga Barabadze on 22.10.19.
//  Copyright © 2019 Goga Barabadze. All rights reserved.
//

import Foundation

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
            
        case .dayMonthYear:
            return "dd.MM.yyyy"
            
        case .dayMonthYearHourMinute:
            return "dd.MM.yyyy HH:mm"
            
        case .dayMonthYearHourMinuteSecondMillisecondTimezone:
            return "dd.MM.yyyy HH:mm:ss:SSS Z"
            
        }
        
    }
    
    static func stringAsDate(style: Date.Style, string: String) -> Date{
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = fromStyleToString(style: style)
        
        return formatter.date(from: string)!
        
    }
    
}
