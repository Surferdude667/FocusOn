//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class GoalTableViewCell: UITableViewCell {
    
    var test = 0
    
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var goalCheckButton: UIButton!
    
    @IBAction func goalCheckButtonTapped(_ sender: Any) {
        if test == 0 {
        goalTextField = CellModifier.lockUnlockTextField(textField: goalTextField, locked: true)
            test = 1
        } else {
            goalTextField = CellModifier.lockUnlockTextField(textField: goalTextField, locked: false)
            test = 0
        }
        
        print("Goal checked!")
    }
}
