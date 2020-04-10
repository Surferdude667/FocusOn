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
    var timeManager = TimeManager()
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    
    // MARK:- Add new data
    
    func addNewEmptyGoalAndTask() {
        let emptyGoal = NSEntityDescription.insertNewObject(forEntityName: Goal.entityName, into: managedContext) as! Goal
        
        emptyGoal.id = UUID()
        emptyGoal.title = ""
        emptyGoal.completed = false
        emptyGoal.creation = timeManager.yesterday
        delegate.goals.append(emptyGoal)
        
        addNewEmptyTask(forGoal: emptyGoal.id)
    }
    
    func addNewEmptyTask(forGoal goalID: UUID) {
        let emptyTask = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: managedContext) as! Task
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: Goal.entityName)
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Goal.id), goalID as CVarArg)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let returnedResult = result as? [Goal] {
                if returnedResult.count != 0 {
                    let fetchedGoal = returnedResult.first!
                    
                    emptyTask.id = UUID()
                    emptyTask.title = ""
                    emptyTask.completed = false
                    emptyTask.goal = fetchedGoal
                    
                } else { print("Fetch result was empty for specified goal id: \(goalID)") }
            }
        } catch { print("Fetch on goal id: \(goalID) failed. \(error)") }
        
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
    func updateOrDeleteGoal(goalID: UUID, newTitle: String? = nil, newCreation: Date? = nil, completed: Bool? = nil, delete: Bool = false) {
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
                        if let newCreation = newCreation { fetchedGoal.creation = newCreation }
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
    func updateOrDeleteTask(taskID: UUID, goalID: UUID, newTitle: String? = nil, completed: Bool? = nil, delete: Bool = false) {
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
    
    func fetchAllGoals() -> [Goal]? {
        let fetchRequest = NSFetchRequest<Goal>(entityName: Goal.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let goals = try managedContext.fetch(fetchRequest)
            return goals
        } catch {
            print("Could not fetch goals. \(error)")
        }
        return nil
    }
    
    // TEST
    func fetchGoals(from date: Date) -> [Goal] {
        let fetchRequest = NSFetchRequest<Goal>(entityName: Goal.entityName)
        fetchRequest.predicate = NSPredicate(format: "creation = %@", timeManager.startOfDay(for: date) as NSDate)
        
        do {
            let goals = try managedContext.fetch(fetchRequest)
            return goals
        } catch {
            print("Could not fetch goals. \(error)")
        }
        return [Goal]()
    }
    
    
    // TEST
    func fetchHistory(from: Date?, to: Date?) -> [Goal]? {
        let fetchRequest = NSFetchRequest<Goal>(entityName: Goal.entityName)
        
        var predicate: NSPredicate?
        if let from = from, let to = to {
            predicate = NSPredicate(format: "creation >= %@ AND creation <= %@", timeManager.startOfDay(for: from) as NSDate, timeManager.startOfDay(for: to) as NSDate)
        } else if let from = from {
            predicate = NSPredicate(format: "creation >= %@ ", timeManager.startOfDay(for: from) as NSDate)
        } else if let to = to {
            predicate = NSPredicate(format: "creation <= %@ ", timeManager.startOfDay(for: to) as NSDate)
        }
        
        fetchRequest.predicate = predicate
        
        let sectionSortDescriptor = NSSortDescriptor(key: "creation", ascending: true)
        fetchRequest.sortDescriptors = [sectionSortDescriptor]
        //fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            print(result)
            return result
        } catch {
           print("Something went wrong \(error)")
        }
        return nil
    }
    
    
}
