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
}

class DataManager {
    
    var delegate: DataManagerDelegate!
    var managedContext: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    
    // MARK:- Add new data
    
    func addNewEmptyGoalAndTask() {
        let emptyGoal = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        let creationDate = Date()
        
        emptyGoal.id = UUID()
        emptyGoal.title = ""
        emptyGoal.completed = false
        emptyGoal.creation = creationDate
        delegate.goals.append(emptyGoal)
        
        addNewEmptyTask(forGoal: emptyGoal.id)
    }
    
    func addNewEmptyTask(forGoal goalID: UUID) {
        let emptyTask = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        let goalWithCorrespondingID = delegate.goals.filter { $0.id == goalID }
        
        emptyTask.id = UUID()
        emptyTask.title = ""
        emptyTask.completed = false
        emptyTask.goal = goalWithCorrespondingID.first!
        
        do {
            try managedContext.save()
        } catch {
            print("Failed to save managed context. \(error)")
            managedContext.rollback()
        }
    }
    
    // MARK:- Update and Delete
    
    // Update or delete goal on specified ID.
    // Provided nill values for optionals will stay untouched.
    func UpdateOrDeleteGoal(goalID: UUID, newTitle: String?, completed: Bool?, delete: Bool) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Goal.entityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Goal.id), goalID as CVarArg)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let returnedResult = result as? [Goal] {
                if returnedResult.count != 0 {
                    let fetchedGoal = returnedResult.first!
                    
                    if delete {
                        // Delete goal (This also deletes all corosponding tasks!)
                        managedContext.delete(fetchedGoal)
                    } else {
                        // Set new values for goal if not nill.
                        if let newTitle = newTitle { fetchedGoal.title = newTitle }
                        if let completed = completed { fetchedGoal.completed = completed }
                    }
                    
                    do {
                        try managedContext.save()
                    } catch {
                        print("Save failed: \(error)")
                        managedContext.rollback()
                    }
                } else { print("Fetch result was empty for specified goal id: \(goalID)") }
            }
        } catch { print("Fetch on goal id: \(goalID) failed. \(error)") }
    }
    
    
    // Update or delete task on specified IDs.
    // Provided nill values for optionals will stay untouched.
    func updateOrDeleteTask(taskID: UUID, goalID: UUID, newTitle: String?, completed: Bool?, delete: Bool) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Task.entityName)
        let withGoalIDPredicate = NSPredicate(format: "%K == %@", #keyPath(Task.goal.id), "\(goalID)")
        let findTaskPredicate = NSPredicate(format: "%K == %@", #keyPath(Task.id), "\(taskID)")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [withGoalIDPredicate, findTaskPredicate])
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let returnedResult = result as? [Task] {
                if returnedResult.count != 0 {
                    let fetchedTask = returnedResult.first!
                    
                    if delete {
                        // Delete goal (This also deletes all corosponding tasks!)
                        managedContext.delete(fetchedTask)
                    } else {
                        // Set new values for goal if not nill.
                        if let newTitle = newTitle { fetchedTask.title = newTitle }
                        if let completed = completed { fetchedTask.completed = completed }
                    }
                                        
                    do {
                        try managedContext.save()
                    } catch {
                        print("Save failed: \(error)")
                        managedContext.rollback()
                    }
                } else {
                    print("Fetch result was empty for specified task id: \(taskID), goal id: \(goalID).")
                }
            }
        } catch {
            print("Fetch on task id: \(taskID), goal id: \(goalID) failed. \(error)")
        }
    }
    
    
    // MARK:- Fetch
    
    func fetchAllGoals() {
        let fetchRequest = NSFetchRequest<Goal>(entityName: Goal.entityName)
        
        do {
            let goals = try managedContext.fetch(fetchRequest)
            delegate?.goals.append(contentsOf: goals)
        } catch {
            print("Could not fetch goals. \(error)")
        }
    }
    
}
