//
//  HistoryManager.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 10/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

struct History {
    var date: String // Date of section.
    var summary: String? // Summary of month.
    var goals: [Goal]? // Goals in section.
    var type: historyType // Type of data in section.
    
    enum historyType {
        case month
        case day
    }
}

struct MonthDayGoals {
    var month: Int
    var day: Int
    var goals: [Goal]?
}

class HistoryManager {
    
    var timeManager = TimeManager()
    
    func sortHistoryData(goals: [Goal]) -> [History] {
        var finalResult = [History]()
        
        // MARK:- Total months
        // Find total number og months in all goals.
        var monthOfAllGoals = [String]()
        for goal in goals { monthOfAllGoals.append(timeManager.formattedMonth(for: goal.creation)) }
        let numberOfDifferentMonths = NSOrderedSet(array: monthOfAllGoals.map { $0 })
        
        // MARK:- Calculated data
        // All the necessary variables of data to do the sorting.
        let differentMonths = Array(numberOfDifferentMonths) as! [String]
        var goalsInEachMonth = [[Goal?]](repeatElement([nil], count: differentMonths.count))
        var summaryForEachMonth = [String]()
        var totalDaysInMonth = [[String]]()
        var collectionOfGoalsInMonthAndDay = [MonthDayGoals]()
        
        // MARK:- Goals in months
        // Find all goals in each month.
        for goal in goals {
            for month in 0..<differentMonths.count {
                if timeManager.formattedMonth(for: goal.creation) == differentMonths[month] {
                    goalsInEachMonth[month].append(goal)
                }
            }
        }
        
        // MARK:- Summary for months
        // Calculate summary for each month.
        for month in 0..<differentMonths.count {
            let totalGoalsInMonth = goalsInEachMonth[month].count - 1
            var completedGoalsInMonth = 0
            
            for goal in goalsInEachMonth[month] {
                if goal != nil && goal!.completed {
                    completedGoalsInMonth += 1
                }
            }
            
            summaryForEachMonth.append("Summary for \(differentMonths[month]): \(completedGoalsInMonth)/\(totalGoalsInMonth) completed")
            completedGoalsInMonth = 0
        }
        
        // MARK:- Days in months
        // Find all days in each month
        var dayOfAllGoalsInMonth = [[String?]](repeatElement([nil], count: differentMonths.count))
        
        for month in 0..<differentMonths.count {
            for goal in goalsInEachMonth[month] {
                if goal != nil {
                    dayOfAllGoalsInMonth[month].append(timeManager.formattedDay(for: goal!.creation))
                }
            }
        }
        
        for i in 0..<differentMonths.count {
            var daysInMonth = [String]()
            
            for day in dayOfAllGoalsInMonth[i] {
                if day != nil {
                    daysInMonth.append(day!)
                }
            }
            
            let numberOfDifferentDays = NSOrderedSet(array: daysInMonth.map { $0 })
            let differentDays = Array(numberOfDifferentDays) as! [String]
            totalDaysInMonth.append(differentDays)
        }
        
        // MARK:- Goals in days
        // Find all goals in each day.
        for month in 0..<differentMonths.count {
            for day in 0..<totalDaysInMonth[month].count {
                
                var goals = [Goal]()
                
                for goal in goalsInEachMonth[month] {
                    if goal != nil {
                        if timeManager.formattedDay(for: goal!.creation) == totalDaysInMonth[month][day] {
                            goals.append(goal!)
                        }
                    }
                }
                collectionOfGoalsInMonthAndDay.append(MonthDayGoals(month: month, day: day, goals: goals))
            }
        }
        
        // MARK:- Final result creation
        // Create filtered result.
        for month in 0..<differentMonths.count {
            finalResult.append(History(date: differentMonths[month], summary: summaryForEachMonth[month], goals: nil, type: .month))
            
            for day in 0..<totalDaysInMonth[month].count {
                for goal in collectionOfGoalsInMonthAndDay {
                    if goal.month == month {
                        if goal.day == day {
                            finalResult.append(History(date: totalDaysInMonth[month][day], summary: nil, goals: goal.goals, type: .day))
                        }
                    }
                }
            }
        }
        
        return finalResult
    }
    
    
}
