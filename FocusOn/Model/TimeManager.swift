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
        dateFormatter.dateFormat = "LLLL"
        let nameOfMonth = dateFormatter.string(from: date)
        
        return nameOfMonth
    }
}
