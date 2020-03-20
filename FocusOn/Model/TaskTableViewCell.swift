//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var taskCheckButton: UIButton!
    
    
    
    
    @IBAction func taskCheckButtonTapped(_ sender: Any) {
        taskTextField = CellModifier.lockUnlockTextField(textField: taskTextField, locked: true)
        print("Task checked!")
    }
}
