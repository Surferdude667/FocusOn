//
//  DemoManager.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 06/05/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation
import CoreData

class DemoManager {
    
    private var managedContext = DataManager().managedContext
    private var timeManager = TimeManager()
    
    func populateDemoData() {
        
        
        // ----- GOAL 1 (YESTERDAY) -----  //
        let goal1 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        goal1.id = UUID()
        goal1.creation = timeManager.yesterday
        goal1.title = "Clean the House"
        goal1.completed = false
        
        let task1goal1 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task1goal1.id = UUID()
        task1goal1.title = "Kitchen"
        task1goal1.completed = false
        task1goal1.goal = goal1
        
        let task2goal1 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task2goal1.id = UUID()
        task2goal1.title = "Bathroom"
        task2goal1.completed = false
        task2goal1.goal = goal1
        
        let task3goal1 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task3goal1.id = UUID()
        task3goal1.title = "Office room"
        task3goal1.completed = false
        task3goal1.goal = goal1
        
        let task4goal1 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task4goal1.id = UUID()
        task4goal1.title = "Bedroom"
        task4goal1.completed = false
        task4goal1.goal = goal1
        
        let task5goal1 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task5goal1.id = UUID()
        task5goal1.title = ""
        task5goal1.completed = false
        task5goal1.goal = goal1
        
        // ----- GOAL 2 (YESTERDAY) -----  //
        let goal2 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        goal2.id = UUID()
        goal2.creation = timeManager.yesterday
        goal2.title = "Have fun!"
        goal2.completed = false
        
        let task1goal2 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task1goal2.id = UUID()
        task1goal2.title = "Go surfing"
        task1goal2.completed = false
        task1goal2.goal = goal2
        
        let task2goal2 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task2goal2.id = UUID()
        task2goal2.title = "Eat chips'n dip"
        task2goal2.completed = true
        task2goal2.goal = goal2
        
        let task3goal2 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task3goal2.id = UUID()
        task3goal2.title = "Watch TV"
        task3goal2.completed = true
        task3goal2.goal = goal2
        
        let task4goal2 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task4goal2.id = UUID()
        task4goal2.title = ""
        task4goal2.completed = false
        task4goal2.goal = goal2
        
        // ----- GOAL 3 (YESTERDAY) -----  //
        let goal3 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        goal3.id = UUID()
        goal3.creation = timeManager.yesterday
        goal3.title = "Homework"
        goal3.completed = true

        let task1goal3 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task1goal3.id = UUID()
        task1goal3.title = "Create Unit tests"
        task1goal3.completed = true
        task1goal3.goal = goal3
        
        let task2goal3 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task2goal3.id = UUID()
        task2goal3.title = "Make DEMO function"
        task2goal3.completed = true
        task2goal3.goal = goal3
        
        let task3goal3 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task3goal3.id = UUID()
        task3goal3.title = "Mentor session"
        task3goal3.completed = true
        task3goal3.goal = goal3
        
        let task4goal3 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task4goal3.id = UUID()
        task4goal3.title = ""
        task4goal3.completed = false
        task4goal3.goal = goal3
        
        // ----- GOAL 4 (LAST WEEK) -----  //
        
        let goal4 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        goal4.id = UUID()
        goal4.creation = timeManager.lastWeek
        goal4.title = "Shopping"
        goal4.completed = false

        let task1goal4 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task1goal4.id = UUID()
        task1goal4.title = "Milk"
        task1goal4.completed = false
        task1goal4.goal = goal4
        
        let task2goal4 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task2goal4.id = UUID()
        task2goal4.title = "Honey"
        task2goal4.completed = false
        task2goal4.goal = goal4
        
        let task3goal4 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task3goal4.id = UUID()
        task3goal4.title = "Juice"
        task3goal4.completed = true
        task3goal4.goal = goal4
        
        let task4goal4 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task4goal4.id = UUID()
        task4goal4.title = ""
        task4goal4.completed = false
        task4goal4.goal = goal4
        
        
        // ----- GOAL 5 (LAST MONTH) -----  //
        
        let goal5 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        goal5.id = UUID()
        goal5.creation = timeManager.lastMonth
        goal5.title = "Work"
        goal5.completed = false

        let task1goal5 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task1goal5.id = UUID()
        task1goal5.title = "Make banner"
        task1goal5.completed = false
        task1goal5.goal = goal5
        
        let task2goal5 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task2goal5.id = UUID()
        task2goal5.title = "Edit picture"
        task2goal5.completed = true
        task2goal5.goal = goal5
        
        let task3goal5 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task3goal5.id = UUID()
        task3goal5.title = "Documentation"
        task3goal5.completed = true
        task3goal5.goal = goal5
        
        let task4goal5 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task4goal5.id = UUID()
        task4goal5.title = ""
        task4goal5.completed = false
        task4goal5.goal = goal5
        
        // ----- GOAL 6 (TWO MONTHS AGO) -----  //
        
        let goal6 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        goal6.id = UUID()
        goal6.creation = timeManager.twoMonthsAgo
        goal6.title = "See freinds"
        goal6.completed = true

        let task1goal6 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task1goal6.id = UUID()
        task1goal6.title = "Drive to Aalborg"
        task1goal6.completed = true
        task1goal6.goal = goal6
        
        let task2goal6 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task2goal6.id = UUID()
        task2goal6.title = "Buy beer"
        task2goal6.completed = true
        task2goal6.goal = goal6
        
        let task3goal6 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task3goal6.id = UUID()
        task3goal6.title = "Drink beer"
        task3goal6.completed = true
        task3goal6.goal = goal6
        
        let task4goal6 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        task4goal6.id = UUID()
        task4goal6.title = ""
        task4goal6.completed = true
        task4goal6.goal = goal6
        
        
        do {
            try managedContext.save()
        } catch {
            print("Failed to save managed context. \(error)")
            managedContext.rollback()
        }
        
    }
    
}
