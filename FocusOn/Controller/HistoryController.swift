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
    
        
    struct DayHistory {
        let day: String
        let entries: [Goal]
    }
    
    struct MonthHistory {
        let month: String
        let summary: String
        let entries: [DayHistory]
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
                
                var completed = 0
                let total = goalsForThisMonth.count
                
                for goalInMonth in goalsForThisMonth {
                    for goal in goalInMonth.entries {
                        if goal.completed {
                            completed += 1
                        }
                    }
                }
                
                result.append(MonthHistory(month: currentMonth!, summary: "Summary: \(completed)/\(total)", entries: goalsForThisMonth))
                currentMonth = timeManager.formattedMonth(for: date)
                goalsForThisMonth.removeAll()
            
            }
        }
        
        for goal in goals {
            if currentMonth == nil { currentMonth = timeManager.formattedMonth(for: goal.creation) }
            if currentDay == nil { currentDay = timeManager.formattedDay(for: goal.creation) }
            
            
            
            // ------------------------ IF CURRENT MONTH START ------------------------ //
            if currentMonth == timeManager.formattedMonth(for: goal.creation) {
                
                goalsIterated += 1
                print(totalGoalsProvided)
                print("Iter: \(goalsIterated)")
                // ------------------------ IF CURRENT DAY START ------------------------ //
                if currentDay == timeManager.formattedDay(for: goal.creation) {
                    goalsForThisDay.append(goal)
                } else {
                    
                    if goalsForThisDay.count != 0 {
                        goalsForThisMonth.append(DayHistory(day: currentDay!, entries: goalsForThisDay))
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
        completeHistory = dataManager.fetchHistory(from: nil, to: nil)
        print(createMontlyHistory(with: completeHistory!))
        historyByMonth = createMontlyHistory(with: completeHistory!)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyByMonth[section].entries.count + historyByMonth.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        

        
        cell.textLabel?.text = completeHistory![indexPath.row].title
        return cell
    }
    
}
