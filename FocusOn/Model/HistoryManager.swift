//
//  HistoryManager.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 10/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

struct History {
    var date: String // Section header
    var headline: String? // Always first cell
    var descriptions: [Goal]? // This is for all the tasks. Always nill if HistoryType .month
    var type: historyType // Shows if the data is month or day.
    
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
        
        // Find number og months
        var monthOfAllGoals = [String]()
        for goal in goals { monthOfAllGoals.append(timeManager.formattedMonth(for: goal.creation)) }
        let numberOfDifferentMonths = NSOrderedSet(array: monthOfAllGoals.map { $0 })
        
        // ---- DATA ----
        let differentMonths = Array(numberOfDifferentMonths) as! [String]
        var goalsInEachMonth = [[Goal?]](repeatElement([nil], count: differentMonths.count))
        var summaryForEachMonth = [String]()
        var totalDaysInMonth = [[String]]()
        var collectionOfGoalsInMonthAndDay = [MonthDayGoals]()
        
        for goal in goals {
            for month in 0..<differentMonths.count {
                if timeManager.formattedMonth(for: goal.creation) == differentMonths[month] {
                    goalsInEachMonth[month].append(goal)
                }
            }
        }
        
        
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
        
        
        for month in 0..<differentMonths.count {
            finalResult.append(History(date: differentMonths[month], headline: summaryForEachMonth[month], descriptions: nil, type: .month))
            print("Month: \(differentMonths[month]).")
            
            
            for day in 0..<totalDaysInMonth[month].count {
                print("Day: \(totalDaysInMonth[month][day])")
                                
                
                for goal in collectionOfGoalsInMonthAndDay {
                    if goal.month == month {
                        if goal.day == day {
                            
                            finalResult.append(History(date: totalDaysInMonth[month][day], headline: nil, descriptions: goal.goals, type: .day))
                            
                            for G in goal.goals! {
                                print("Goal: \(G.title)")
                            }
                        }
                    }
                }
            }
        }
        

        return finalResult
    }
    
}
