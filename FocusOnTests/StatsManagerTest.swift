//
//  StatsManagerTest.swift
//  FocusOnTests
//
//  Created by Bjørn Lau Jørgensen on 22/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class StatsManagerTest: XCTestCase {
    
    var dataManager: DataManager!
    var timeManager: TimeManager!
    var statsManager: StatsManager!
    var managedContext: NSManagedObjectContext!
    
    var goals = [Goal]()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataManager = DataManager()
        timeManager = TimeManager()
        statsManager = StatsManager()
        managedContext = dataManager.managedContext
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dataManager = nil
        timeManager = nil
        managedContext = nil
        statsManager = nil
    }

    // Tests if the Stats object contains the correct return values from the createStats() function.
    func testIfOutputIsCorrect() {
        let goal1 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        let goal2 = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        
        goal1.id = UUID()
        goal1.title = "Goal 1"
        goal1.completed = false
        goal1.creation = timeManager.yesterday
        
        goal2.id = UUID()
        goal2.title = "Goal 2"
        goal2.completed = true
        goal2.creation = timeManager.today
        
        goals.append(goal1)
        goals.append(goal2)
        
        let statsOnlyGoals = statsManager.createStats(from: goals, tasksOnly: false)
        
        // Test that the dates are mapped correctly.
        XCTAssert(statsOnlyGoals!.from == timeManager.formattedDay(for: goal1.creation))
        XCTAssert(statsOnlyGoals!.to == timeManager.formattedDay(for: goal2.creation))
        
        // Test that the completion calculations is correct.
        XCTAssert(statsOnlyGoals!.completed == 1)
        XCTAssert(statsOnlyGoals!.uncompleted == 1)
        XCTAssert(statsOnlyGoals!.percent == 50)
        
        let task1ForGoal1 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        let task2ForGoal1 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        
        let task1ForGoal2 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        let task2ForGoal2 = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        
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
        
        let statsOnlyTasks = statsManager.createStats(from: goals, tasksOnly: true)
        
        // Check if everything calculates correctley on the tasks.
        XCTAssert(statsOnlyTasks!.completed == 3)
        XCTAssert(statsOnlyTasks!.uncompleted == 1)
        XCTAssert(statsOnlyTasks!.percent == 75)
    }

}
