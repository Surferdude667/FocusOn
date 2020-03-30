//
//  DataManager.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 27/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import CoreData

protocol DataManagerDelegate {
    var goals: [Goal] { get set }
    var tasks: [Task] { get set }
}

class DataManager {
    
    var delegate: DataManagerDelegate!
    
    // Adds a new goal to CoreData.
    // TODO: Return id
    func addNewGoalAndSave() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let goal = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        
        // Experiment
        let task = Task(context: managedContext)
        task.title = "Empty"
        task.completed = false
        task.goal = goal
        
        
        //goal.id = Int16(delegate.goals.count)
        goal.id = Int16(99)
        goal.title = "Goal #10"
        goal.completed = false
        goal.creation = nil
        goal.tasks = NSSet(array: [task])        
        
        do {
            try managedContext.save()
            delegate.goals.append(goal)
            delegate.tasks.append(task)
        } catch {
            print("Could not save. \(error)")
            managedContext.rollback()
        }
    }
    
    func addNewTaskAndSave() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let task = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        
        let goalWithCorrespondingID = delegate.goals.filter { $0.id == Int16(5) }
        
        task.title = "Task #2"
        task.completed = false
        task.goal = goalWithCorrespondingID.first!
        
        do {
            try managedContext.save()
            delegate?.tasks.append(task)
        } catch {
            print("There was a problem on update \(error)")
            managedContext.rollback()
        }
    }
    
    
    func UpdateGoal() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Goal.entityName)
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Goal.id), "99")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let returnedResult = result as? [Goal] {
                if returnedResult.count != 0 {
                    let objectUpdate = returnedResult.first!
                    
                    
                    // Set new values.
                    objectUpdate.title = "New title"
                
                    
                    do { try managedContext.save() } catch { print(error); managedContext.rollback() }
                } else { print("Could not find specified ID") }
            }
        } catch { print("Damn: \(error)") }
    }
    
    
    
    func updateTask() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Task.entityName)
        
        let withGoalIDPredicate = NSPredicate(format: "%K == %@", #keyPath(Task.goal.id), "7")
        let findTaskPredicate = NSPredicate(format: "%K == %@", #keyPath(Task.title), "Task #2")
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [withGoalIDPredicate, findTaskPredicate])
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let value = result as? [Task] {
                if value.count != 0 {
                    let objectUpdate = value.first!
                    
                    
                    // Set new values
                    objectUpdate.title = "Du blev opdateret!"
                    objectUpdate.completed = true
                    
                    do {
                        try managedContext.save()
                    } catch {
                        print(error)
                        managedContext.rollback()
                    }
                    
//                    for element in value {
//                        print(element.title)
//                    }
                }
            }
            
            
        } catch {
            print(error)
        }
    }
    
    
    
    
    // MARK:- Fetch
    
    func fetchAllGoals() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Goal>(entityName: Goal.entityName)
        
        do {
            let goals = try managedContext.fetch(fetchRequest)
            delegate?.goals.append(contentsOf: goals)
        } catch {
            print("Could not fetch goals. \(error)")
        }
    }
    
    func fetchAllTasks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Task>(entityName: Task.entityName)
        
        do {
            let tasks = try managedContext.fetch(fetchRequest)
            delegate?.tasks.append(contentsOf: tasks)
        } catch {
            print("Could not fetch tasks. \(error)")
        }
    }
    
}
