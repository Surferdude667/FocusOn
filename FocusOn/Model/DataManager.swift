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
    
    var delegate: DataManagerDelegate?
    
    // Adds a new goal to CoreData.
    // TODO: Return id
    func addNewGoalAndSave() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let goal = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        
        goal.id = Int16(5)
        goal.title = "Goal #1"
        goal.completed = false
        goal.creation = nil
        
        do {
            try managedContext.save()
            delegate?.goals.append(goal)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            managedContext.rollback()
        }
    }
    
    func addNewTaskAndSave() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let task = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        
        let goalID = delegate?.goals.filter { $0.id == Int16(5) }
        
        task.title = "Task #2"
        task.completed = false
        task.goal = goalID!.first!
        
        do {
            try managedContext.save()
            delegate?.tasks.append(task)
        } catch {
            print("There was a problem on update \(error)")
            managedContext.rollback()
        }
    }
    
    
    func updateAndSave() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Goal.entityName)
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Goal.id), "10")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let result = result as? [Goal] {
                if result.count != 0 {
                    let objectUpdate = result.first!
                    
                    objectUpdate.id = Int16(11)
                    
                } else {
                    print("Could not find specified ID")
                }
            }
            
            do { try managedContext.save() }
            catch { print(error) }
            
        } catch { print(error) }
    }
    
    func fetchAllGoals() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Goal>(entityName: Goal.entityName)
        
        do {
            let goals = try managedContext.fetch(fetchRequest)
            delegate?.goals.append(contentsOf: goals)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func fetchAllTasks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Task>(entityName: Task.entityName)
        
        do {
            let tasks = try managedContext.fetch(fetchRequest)
            delegate?.tasks.append(contentsOf: tasks)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}
