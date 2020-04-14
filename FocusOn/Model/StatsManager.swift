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
    
    // TODO: This needs to be more safe in case of no data.
    func thisMonth() -> Stats {
        let firstDayInMonth = timeManger.startOfMonth(for: Date())
        let goals = dataManager.fetchHistory(from: firstDayInMonth, to: Date())
        var completed = 0.0
        var uncompleted = 0.0
        
        if goals != nil {
            for goal in goals! {
                if goal.completed == true {
                    completed += 1
                } else if goal.completed == false {
                    uncompleted += 1
                }
            }
        }
        
        // TODO: Make sure what heppens if there is 100 tasks and 99 is completed. Will it write 100%?
        let percent = completed * 100 / (completed + uncompleted)
        let stats = Stats(completed: Int(completed),
                          uncompleted: Int(uncompleted),
                          percent: Int(percent),
                          from: timeManger.formattedDay(for: firstDayInMonth),
                          to: timeManger.formattedDay(for: Date()))
        return stats
    }
    
    
    
}
