//
//  DataManagerTest.swift
//  FocusOnTests
//
//  Created by Bjørn Lau Jørgensen on 04/05/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import XCTest
import CoreData
@testable import FocusOn

class DataManagerTest: XCTestCase {
    
    var dataManager: DataManager!
    var timeManager: TimeManager!
    var managedContext: NSManagedObjectContext!
    var objectsBeforeCreation: Int!
    var objectsAfterCreation: Int?
    
    var goals = [Goal]()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataManager = DataManager()
        timeManager = TimeManager()
        managedContext = dataManager.managedContext
        objectsBeforeCreation = managedContext.registeredObjects.count
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dataManager = nil
        timeManager = nil
        managedContext = nil
        objectsBeforeCreation = nil
    }
    
    
    // Add ned goal and task.
    // Testing if 2 objects are added to the managedContext after creation function is excecuted.
    // Should add 1 goal and 1 task.
    func testAddGoalAndTask() {
        let id = dataManager.addNewEmptyGoalAndTask()
        objectsAfterCreation = managedContext.registeredObjects.count
        XCTAssert(objectsBeforeCreation! + 2 == objectsAfterCreation)
        deleteGoalFromContext(id: id)
    }
    
    // HELPER FUNCTION - Tested above.
    func addGoalToContext() -> UUID {
        let id = dataManager.addNewEmptyGoalAndTask()
        return id
    }
    
    // Testing if the number of objects are back the same as before the creation.
    func testDeleteGoal() {
        let id = addGoalToContext()
        dataManager.updateOrDeleteGoal(goalID: id, delete: true)
        objectsAfterCreation = managedContext.registeredObjects.count
        XCTAssert(objectsBeforeCreation! == objectsAfterCreation)
    }
    
    // HELPER FUNCTION - Tested above.
    func deleteGoalFromContext(id: UUID) {
        dataManager.updateOrDeleteGoal(goalID: id, delete: true)
    }
    
    // Testing if a task is deleted.
    func testDeleteTask() {
        let goalID = addGoalToContext()
        var task: Task?
        
        for object in managedContext.registeredObjects {
            if object.entity.name == Goal.entityName {
                let goal = object as! Goal
                if goal.id == goalID {
                    task = goal.tasks?.allObjects[0] as? Task
                    
                    if let task = task {
                        dataManager.updateOrDeleteTask(taskID: task.id, goalID: goalID, delete: true)
                    }
                }
            }
        }
        
        for object in managedContext.registeredObjects {
            if object.entity.name == Goal.entityName {
                let goal = object as! Goal
                if goal.id == goalID {
                    XCTAssert(goal.tasks?.allObjects.count == 0)
                }
            }
        }
        
        deleteGoalFromContext(id: goalID)
    }
    
    // Testing if the goal object is updated.
    func testGoalUpdate() {
        let id = addGoalToContext()
        dataManager.updateOrDeleteGoal(goalID: id, newTitle: "New title", newCreation: timeManager.yesterday, completed: true)
        
        for object in managedContext.registeredObjects {
            if object.entity.name == Goal.entityName {
                let goal = object as! Goal
                
                if goal.id == id {
                    XCTAssert(goal.title == "New title")
                    XCTAssert(goal.creation == timeManager.yesterday)
                    XCTAssert(goal.completed == true)
                }
            }
        }
        deleteGoalFromContext(id: id)
    }
    
    // Testing if task object is updated.
    func testTaskUpdate() {
        let goalID = addGoalToContext()
        var task: Task?
        
        for object in managedContext.registeredObjects {
            if object.entity.name == Goal.entityName {
                let goal = object as! Goal
                if goal.id == goalID {
                    task = goal.tasks?.allObjects[0] as? Task
                }
            }
        }
        
        if let task = task {
            dataManager.updateOrDeleteTask(taskID: task.id, goalID: goalID, newTitle: "NewTaskTitle", completed: true)
        }
        
        for object in managedContext.registeredObjects {
            if object.entity.name == Task.entityName {
                let updatedTask = object as! Task
                if updatedTask.id == task!.id {
                    XCTAssert(updatedTask.title == "NewTaskTitle")
                    XCTAssert(updatedTask.completed == true)
                }
            }
        }
        deleteGoalFromContext(id: goalID)
    }
    
    func testFetchAllGoals() {
        let goal1 = addGoalToContext()
        let goal2 = addGoalToContext()
        let goal3 = addGoalToContext()
        
        let fetchResult = dataManager.fetchAllGoals()
        XCTAssert(fetchResult!.count >= 3)
        
        deleteGoalFromContext(id: goal1)
        deleteGoalFromContext(id: goal2)
        deleteGoalFromContext(id: goal3)
    }
    
    func testFetchGoalsFromSpecificDay() {
        let goal1 = addGoalToContext()
        let goal2 = addGoalToContext()
        let goal3 = addGoalToContext()
        
        let fetchResult = dataManager.fetchGoals(from: timeManager.today)
        XCTAssert(fetchResult.count >= 3)
        
        deleteGoalFromContext(id: goal1)
        deleteGoalFromContext(id: goal2)
        deleteGoalFromContext(id: goal3)
    }
    
    func testFetchHistory() {
        let goal1 = addGoalToContext()
        let goal2 = addGoalToContext()
        
        let fetchResult = dataManager.fetchHistory(from: timeManager.today, to: timeManager.today)
        XCTAssert(fetchResult!.count >= 2)
        
        deleteGoalFromContext(id: goal1)
        deleteGoalFromContext(id: goal2)
    }
    
    
}
