//
//  HistoryController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 18/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import CoreData

class HistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var dataManager = DataManager()
    var timeManager = TimeManager()
    var completeHistory: [Goal]?
    var historyByMonth = [MonthHistory]()
    
    
    struct History {
        var date: String // Section header
        var headline: String // Always first cell
        var descriptions: [String]? // This is for all the tasks. Always nill if HistoryType .month
        var type: historyType // Shows if the data is month or day.
        
        enum historyType {
            case month
            case day
        }
    }
    
    
    func sortHistoryData(goals: [Goal]) -> [History] {
        
        var finalResult = [History]()
        
        
        // Find number og months
        var monthOfAllGoals = [String]()
        for goal in goals { monthOfAllGoals.append(timeManager.formattedMonth(for: goal.creation)) }
        let numberOfDifferentMonths = NSOrderedSet(array: monthOfAllGoals.map { $0 })
        
        // DATA
        let differentMonths = Array(numberOfDifferentMonths) as! [String]
        var goalsInEachMonth = [[Goal?]](repeatElement([nil], count: differentMonths.count))
        var summaryForEachMonth = [String]()
        var totalDaysInMonth = [[String]]()
        
        
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
                    //print("Month: \(differentMonths[i]), Day: \(day)")
                }
            }
            
            let numberOfDifferentDays = NSOrderedSet(array: daysInMonth.map { $0 })
            let differentDays = Array(numberOfDifferentDays) as! [String]
            totalDaysInMonth.append(differentDays)
        }
        
        //print(totalDaysInMonth)
        
        // [Month : [Day : [Goals]]
        //var goalsInDaysOfMonth = [Int : [Int : Goal]]()
        

        
        
        
//        var goalsInEachDay = [[[Goal?]]](repeatElement([[nil]], count: differentMonths.count))
//
//        for month in 0..<differentMonths.count {
//            for day in 0..<totalDaysInMonth[month].count {
//
//
//                var dayInMonth = [[Goal]]()
//                var goalInDay = [Goal]()
//
//
//                for goal in goalsInEachMonth[month] {
//                    if goal != nil {
//                        if timeManager.formattedDay(for: goal!.creation) == totalDaysInMonth[month][day] {
//                            goalInDay.append(goal!)
//                        }
//                    }
//                }
//
//
//                dayInMonth.append(goalInDay)
//                goalsInEachDay.append(dayInMonth)
//                goalInDay.removeAll()
//            }
//        }
//
//
//
//
//
//
//        var goalsInEachDay = [[Goal]]()
//
//        for month in 0..<differentMonths.count {
//            for day in 0..<totalDaysInMonth[month].count {
//
//                var goalInDay = [Goal]()
//
//                for goal in goalsInEachMonth[month] {
//                    if goal != nil {
//                        if timeManager.formattedDay(for: goal!.creation) == totalDaysInMonth[month][day] {
//                            goalInDay.append(goal!)
//
//                        }
//                    }
//                }
//                goalsInEachDay.append(goalInDay)
//                goalInDay.removeAll()
//            }
//        }
        
        
        
        
        //print(differentMonths)
        //print(goalsInEachMonth)
        //print(summaryForEachMonth)
        //print(totalDaysInMonth)
        //print(goalsInEachDay.description)
        
        
        // [Days[Goals]]
        
//        for month in 0..<differentMonths.count {
//            print("Month: \(differentMonths[month])")
//            for day in 0..<totalDaysInMonth[month].count {
//                print("Day: \(totalDaysInMonth[month][day])")
//
//
//
//            }
//        }
        
        
        
        struct MonthDayGoals {
            var month: Int
            var day: Int
            var goals: [Goal]
        }
        
        var collectionOfGoalsInMonthAndDay = [MonthDayGoals]()
        
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
        
        //print(collectionOfGoalsInMonthAndDay)
        
        
        for month in 0..<differentMonths.count {
            finalResult.append(History(date: differentMonths[month], headline: summaryForEachMonth[month], descriptions: nil, type: .month))
            print("Month: \(differentMonths[month]).")
            
            
            for day in 0..<totalDaysInMonth[month].count {
                print("Day: \(totalDaysInMonth[month][day])")
                                
                
                for goal in collectionOfGoalsInMonthAndDay {
                    if goal.month == month {
                        if goal.day == day {
                            
                            finalResult.append(History(date: totalDaysInMonth[month][day], headline: <#T##String#>, descriptions: <#T##[String]?#>, type: <#T##History.historyType#>))
                            
                            for G in goal.goals {
                                print("Goal: \(G.title)")
                            }
                        }
                     
                        
                        
                        //finalResult.append(History(date: totalDaysInMonth[month][day], headline: goal, descriptions: <#T##[String]?#>, type: <#T##History.historyType#>))
                        
                    }
                }
            }
            
            
        }
        
        
        
        
//        for month in 0..<differentMonths.count {
//            finalResult.append(History(date: differentMonths[month], headline: summaryForEachMonth[month], descriptions: nil, type: .month))
//
//            for day in 0..<totalDaysInMonth.count {
//
//                var goalsInDay : [Goal] {
//                    for goal in totalCollection {
//                        if goal.day == day && goal.month == month {
//                            return goal.goals
//                        }
//                    }
//                    return [Goal]()
//                }
//
//                var goalsInDayAsString = [String]()
//                print(goalsInDayAsString)
//
//                for goal in goalsInDay {
//                    goalsInDayAsString.append(goal.title)
//                }
//
//
//                //finalResult.append(History(date: totalDaysInMonth[month][day], headline: goalsInDayAsString[day], descriptions: goalsInDayAsString, type: .day))
//            }
//
//        }
        
        
        
        return [History]()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    struct DayHistory {
        let day: String
        let goals: [Goal]
    }
    
    struct MonthHistory {
        let month: String
        let summary: String
        let days: [DayHistory]
    }
    
    
    func createMontlyHistory(with goals: [Goal]) -> [MonthHistory] {
        var goalsForThisDay = [Goal]()
        var goalsForThisMonth = [DayHistory]()
        var result = [MonthHistory]()
        
        let totalGoalsProvided = goals.count
        var goalsIterated = 0
        
        var currentMonth: String?
        var currentDay: String?
        
        func saveToMonth(date: Date) {
            if goalsForThisMonth.count != 0 {
                
                // TODO: This calculates wrong...
                var completed = 0
                let total = goalsForThisMonth.count
                
                for goalInMonth in goalsForThisMonth {
                    for goal in goalInMonth.goals {
                        if goal.completed {
                            completed += 1
                        }
                    }
                }
                
                result.append(MonthHistory(month: currentMonth!, summary: "Summary: \(completed)/\(total)", days: goalsForThisMonth))
                currentMonth = timeManager.formattedMonth(for: date)
                goalsForThisMonth.removeAll()
            
            }
        }
        
        for goal in goals {
            if currentMonth == nil { currentMonth = timeManager.formattedMonth(for: goal.creation) }
            if currentDay == nil { currentDay = timeManager.formattedDay(for: goal.creation) }
            
            goalsIterated += 1
            
            // ------------------------ IF CURRENT MONTH START ------------------------ //
            if currentMonth == timeManager.formattedMonth(for: goal.creation) {
            
                // ------------------------ IF CURRENT DAY START ------------------------ //
                if currentDay == timeManager.formattedDay(for: goal.creation) {
                    goalsForThisDay.append(goal)
                } else {
                    
                    if goalsForThisDay.count != 0 {
                        goalsForThisMonth.append(DayHistory(day: currentDay!, goals: goalsForThisDay))
                        goalsForThisDay.removeAll()
                    }
                    
                    currentDay = timeManager.formattedDay(for: goal.creation)
                    goalsForThisDay.append(goal)
                }
                // ------------------------ IF CURRENT DAY END ------------------------ //
                
                
            } else if currentMonth != timeManager.formattedMonth(for: goal.creation) || goalsIterated == totalGoalsProvided {
                saveToMonth(date: goal.creation)
            }
            
            
            // ------------------------ IF CURRENT MONTH END ------------------------ //
            
            if goalsIterated == totalGoalsProvided || result.count == 0 {
                saveToMonth(date: goal.creation)
            }
            
        }
        //print(result)
        return result
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //completeHistory = dataManager.fetchHistory(from: nil, to: nil)
        
        completeHistory = dataManager.fetchAllGoals()
        
        sortHistoryData(goals: completeHistory!)
        
        
        
        
        
        
        //print(completeHistory)
        historyByMonth = createMontlyHistory(with: completeHistory!)
        //print(historyByMonth)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfMonths = historyByMonth.count
        var numberOfDays = 0
        for month in historyByMonth {
            numberOfDays += month.days.count
        }
        
        //print("TOTAL Sections: \(numberOfDays + numberOfMonths)")
        return numberOfMonths + numberOfDays
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var totalRows = 1

        let numberOfMonths = historyByMonth.count
        for month in 0..<numberOfMonths {
            if month == section {
                for days in 0..<historyByMonth[month].days.count {
                    totalRows += 1
                    for _ in 0..<historyByMonth[month].days[days].goals.count {
                        totalRows += 1
                    }
                }
            }
        }
        print("TOTAL ROWS: \(totalRows) in section \(section)")
        return totalRows
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        
        
        let numberOfMonths = historyByMonth.count
        for monthSection in 0..<numberOfMonths {
            if monthSection == indexPath.section {
                if indexPath.row == 0 {
                   cell.textLabel?.text = historyByMonth[indexPath.section].summary
                }
            } else {
                
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
}
