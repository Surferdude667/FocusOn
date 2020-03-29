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
    var goals: [NSManagedObject] { get set }
}

class DataManager {
    
    var delegate: DataManagerDelegate?
    
    // Adds a new goal to CoreData and returns the Entity ID.
    func addNewGoalAndSave(goal: String, tasks: [Task]) -> Int16? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Goal", in: managedContext)!
        let goalObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let id = Int16(delegate!.goals.count)
        
        // TODO: Needs to set:
        // Current date.
        // Goal ID based on array count.
        // Set the goal completed to false.
        goalObject.setValue(goal, forKey: "goal")
        goalObject.setValue(tasks, forKey: "tasks")
        goalObject.setValue(id, forKey: "id")
        goalObject.setValue(false, forKey: "goalCompleted")
        
        do {
            try managedContext.save()
            delegate?.goals.append(goalObject)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        return id
    }
    
    
    //  Works as expected now.
    func updateAndSave(goalId: Int16, newGoal: String?, newTasks: [Task]?, newDate: Date?, goalCompleted: Bool?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Goal")
        fetchRequest.predicate = NSPredicate(format: "id == \(goalId)")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let result = result as? [NSManagedObject] {
                if result.count != 0 {
                    let objectUpdate = result.first!
                    
                    if let newGoal = newGoal { objectUpdate.setValue(newGoal, forKey: "goal") }
                    if let newTasks = newTasks { objectUpdate.setValue(newTasks, forKey: "tasks") }
                    if let newDate = newDate { objectUpdate.setValue(newDate, forKey: "date") }
                    if let goalCompleted = goalCompleted { objectUpdate.setValue(goalCompleted, forKey: "goalCompleted") }
                } else {
                    print("Could not find specified NSManagedObject with id: \(goalId), to update.")
                }
            }
            
            do { try managedContext.save() }
            catch { print(error) }
            
        } catch { print(error) }
    }
    
    func fetchAllData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Goal")
                
        
        do {
            let goals = try managedContext.fetch(fetchRequest)
            delegate?.goals.append(contentsOf: goals)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
    }
}
