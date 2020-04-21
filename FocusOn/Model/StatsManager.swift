//
//  StatsManager.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 14/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

struct Stats {
    var completed: Int
    var uncompleted: Int
    var percent: Int
    var from: String
    var to: String
}

class StatsManager {
    
    private var dataManager = DataManager()
    private var timeManger = TimeManager()
    
    func createStats(from goals: [Goal]?, tasksOnly: Bool) -> Stats? {

        var completed = 0.0
        var uncompleted = 0.0
        
        guard let goals = goals else { return nil }
        
        if tasksOnly == true {
            for goal in goals {
                let tasks = goal.tasks?.allObjects as? [Task]
                
                if let tasks = tasks {
                    for task in tasks {
                        if task.title != "" {
                        if task.completed == true {
                            completed += 1
                        } else if task.completed == false {
                            uncompleted += 1
                        }
                        }
                    }
                }
            }
        } else if tasksOnly == false {
            for goal in goals {
                if goal.completed == true {
                    completed += 1
                } else if goal.completed == false {
                    uncompleted += 1
                }
            }
        }
        
        let percent = completed * 100 / (completed + uncompleted)
        guard !(percent.isNaN || percent.isInfinite) else { return nil }
        
        let stats = Stats(completed: Int(completed),
                          uncompleted: Int(uncompleted),
                          percent: Int(percent),
                          from: timeManger.formattedDay(for: goals.first!.creation),
                          to: timeManger.formattedDay(for: Date()))
        return stats
    }
    
    
    
}
