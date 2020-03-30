//
//  Task.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 27/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

// NSSecureCoding

public class Task: NSObject, NSCoding {
    //public static var supportsSecureCoding = true
    
    var task = ""
    var completed = false
    
    public func encode(with coder: NSCoder) { }
    public required init?(coder: NSCoder) { }
    
    init(task: String) {
        self.task = task
    }
}
