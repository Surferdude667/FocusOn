//
//  HistoryManagerTest.swift
//  FocusOnTests
//
//  Created by Bjørn Lau Jørgensen on 28/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class HistoryManagerTest: XCTestCase {
    
    var dataManager: DataManager!
    var timeManager: TimeManager!
    var historyManager: HistoryManager!
    var managedContext: NSManagedObjectContext!
    
    var goals = [Goal]()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataManager = DataManager()
        timeManager = TimeManager()
        historyManager = HistoryManager()
        managedContext = dataManager.managedContext
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dataManager = nil
        timeManager = nil
        managedContext = nil
        historyManager = nil
    }

    // Tests if the Stats object contains the correct return values from the createStats() function.
    func testOutputIsCorrect() {
        // ----- GOALS ----- //
        let goal1 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        let goal2 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        let goal3 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        
        // ----- TASKS ----- //
        let task1ForGoal1 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        let task2ForGoal1 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        
        let task1ForGoal2 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        let task2ForGoal2 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        
        let task1ForGoal3 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        let task2ForGoal3 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        
        // ----- GOALS ----- //
        goal1.id = UUID()
        goal1.title = "Goal 1"
        goal1.completed = false
        goal1.creation = timeManager.yesterday
        
        goal2.id = UUID()
        goal2.title = "Goal 2"
        goal2.completed = true
        goal2.creation = timeManager.today
        
        goal3.id = UUID()
        goal3.title = "Goal 3"
        goal3.completed = true
        goal3.creation = timeManager.lastMonth
        
        // ----- TASKS ----- //
        task1ForGoal1.id = UUID()
        task1ForGoal1.title = "task1ForGoal1"
        task1ForGoal1.completed = true
        task1ForGoal1.goal = goal1
        
        task2ForGoal1.id = UUID()
        task2ForGoal1.title = "task2ForGoal1"
        task2ForGoal1.completed = true
        task2ForGoal1.goal = goal1
        
        task1ForGoal2.id = UUID()
        task1ForGoal2.title = "task1ForGoal2"
        task1ForGoal2.completed = false
        task1ForGoal2.goal = goal2
        
        task2ForGoal2.id = UUID()
        task2ForGoal2.title = "task2ForGoal2"
        task2ForGoal2.completed = true
        task2ForGoal2.goal = goal2
        
        task1ForGoal3.id = UUID()
        task1ForGoal3.title = "task1ForGoal3"
        task1ForGoal3.completed = false
        task1ForGoal3.goal = goal3
        
        task2ForGoal3.id = UUID()
        task2ForGoal3.title = "task2ForGoal3"
        task2ForGoal3.completed = true
        task2ForGoal3.goal = goal3
        
        goals.append(goal1)
        goals.append(goal2)
        goals.append(goal3)
        
        let histories = historyManager.sortHistoryData(goals: goals)
        
        var numberOfMonths = 0
        var numberOfDays = 0
        let numberOfGoalsInMonth = histories[2].goals!.count
        
        for history in histories {
            if history.type == .day {
                numberOfDays += 1
            } else if history.type == .month {
                numberOfMonths += 1
            }
        }
                
        // Check if output is correct based on input.
        XCTAssert(histories.count == 5)
        XCTAssert(numberOfMonths == 2)
        XCTAssert(numberOfDays == 3)
        XCTAssert(numberOfGoalsInMonth == 1)
    }

}

