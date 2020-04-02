//
//  Goal.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 30/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation
import CoreData

class Goal: NSManagedObject {
    
    static var entityName: String { return "Goal" }
    
    // Attributes
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var completed: Bool
    @NSManaged var creation: Date
    
    // Relationships
    @NSManaged var tasks: NSMutableSet?
}
