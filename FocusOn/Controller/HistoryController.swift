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
    var history: [Goal]?
    
    
    struct History {
        // ------ SECTION ------ //
        let header: String? // Date
        let summary: String? // Summary of month string
        
        // ------ SECTION FOR EACH goalsAndTasks ------ //
        let goalsAndTasks: [ [Goal : [Task] ] ]?
        
        // HEADER: Goal date.
        // Index 0: Goal
        // Index 0...: Task
    }
    
    
    
    
    
    struct MonthHistory {
        let month: String
        let summary: String
        let entries: [History]
    }
    
    
    
    func populateHistory(goals: [Goal]) -> [History] {
        var result = [History]()
        
        var currentMonth: String?
        
        for goal in goals {
            
            func appendNewGoal() {
                let day = TimeManager().formattedDate(for: goal.creation)
                let tasks = goal.tasks?.allObjects as! [Task]
                result.append(History(header: day, summary: nil, goalsAndTasks: [[goal : tasks]]))
            }
            
            func appendNewMonth() {
                result.append(History(header: currentMonth, summary: "Summary", goalsAndTasks: nil))
            }
            
            
            if currentMonth == nil {
                currentMonth = TimeManager().formattedMonth(for: goal.creation)
                appendNewMonth()
            } else {
                
                if currentMonth != TimeManager().formattedMonth(for: goal.creation) {
                    currentMonth = TimeManager().formattedMonth(for: goal.creation)
                    appendNewMonth()
                    appendNewGoal()
                } else {
                    appendNewGoal()
                }
            }
        }
        return [History]()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        history = dataManager.fetchHistory(from: nil, to: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = history![indexPath.row].title
        return cell
    }
    
}
