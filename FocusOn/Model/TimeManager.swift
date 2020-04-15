//
//  DateHelper.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 07/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

class TimeManager {
    
    var today: Date {
        return startOfDay(for: Date())
    }
    
    var yesterday: Date {
        return startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: today)!)
    }
    
    var lastMonth: Date {
        return startOfDay(for: Calendar.current.date(byAdding: .day, value: -45, to: today)!)
    }
    
    func startOfWeek(for date: Date) -> Date {
        var calender = Calendar.current
        calender.timeZone = TimeZone.current

        return calender.date(from: calender.dateComponents([.weekOfYear, .yearForWeekOfYear], from: Date()))!
    }
    
    func startOfMonth(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        let components = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!

        return startOfMonth
    }
    
    
    func startOfDay(for date: Date) -> Date {
        var calender = Calendar.current
        calender.timeZone = TimeZone.current
        return calender.startOfDay(for: date)
    }
    
    func formattedDate(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.string(from: date)
    }
    
    
    func formattedMonth(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "LLLL yyyy"
        let nameOfMonth = dateFormatter.string(from: date)
        
        return nameOfMonth
    }
    
    func formattedDay(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "MMM d yyyy"
        let nameOfMonth = dateFormatter.string(from: date)
        
        return nameOfMonth
    }
}
