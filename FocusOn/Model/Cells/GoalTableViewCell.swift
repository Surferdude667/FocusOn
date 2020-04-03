//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

protocol GoalCellDelegate {
    func goalTextFieldChangedForCell(cell: GoalTableViewCell, newCaption: String?, oldCaption: String?)
    func goalCheckMarkChangedForCell(at indexPath: IndexPath)
}

class GoalTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: GoalCellDelegate?
    var dataManager = DataManager()
    var indexPath: IndexPath!
    var oldCaption: String?
    var goal: Goal!
    
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var goalCheckButton: UIButton!
    
    func configure() {
        goalTextField.delegate = self
    }
    
    func setGoalCheckMark() {
        if goal.completed {
            goalCheckButton.backgroundColor = UIColor.green
        } else {
            goalCheckButton.backgroundColor = UIColor.red
        }
    }
    
    func processInput(from textField: UITextField?) {
        if let textField = textField {
            let cell = textField.superview?.superview as! GoalTableViewCell
            let newCaption = CellFunctions().fetchInput(textField: textField)
            delegate?.goalTextFieldChangedForCell(cell: cell, newCaption: newCaption, oldCaption: oldCaption)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    
    
    @IBAction func goalEditBegun(_ sender: Any) {
        let textField = sender as? UITextField
        if let textField = textField {
            oldCaption = CellFunctions().fetchInput(textField: textField)
        }
    }
    
    @IBAction func goalEditEnded(_ sender: Any) {
        let textField = sender as? UITextField
        processInput(from: textField)
    }
    
    @IBAction func goalCheckButtonTapped(_ sender: Any) {
        
        // TODO: Mark all corosponding tasks completed with this check.
        // TODO: Move to seperate function.
        if goal.completed == false {
            dataManager.updateOrDeleteGoal(goalID: goal.id, completed: true)
        } else {
            dataManager.updateOrDeleteGoal(goalID: goal.id, completed: false)
        }
        
        delegate?.goalCheckMarkChangedForCell(at: indexPath)
    }
}
