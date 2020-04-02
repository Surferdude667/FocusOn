//
//  Task.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 30/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation
import CoreData

class Task: NSManagedObject {
    
    static var entityName: String { return "Task" }
    
    // Attributes
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var completed: Bool
    @NSManaged var creation: Date
    
    // Relationships
    @NSManaged var goal: Goal
}
