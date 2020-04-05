//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class GoalTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: CellDelegate?
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
            let newCaption = CellFunctions().fetchInput(textField: textField)
            if newCaption != oldCaption {
                dataManager.updateOrDeleteGoal(goalID: goal.id, newTitle: newCaption)
                delegate?.cellChanged(at: indexPath, with: .left)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        print("NIB")
    }
    
    
    @IBAction func goalEditBegun(_ sender: Any) {
        let textField = sender as? UITextField
        if let textField = textField {
            oldCaption = textField.text
        }
    }
    
    @IBAction func goalEditEnded(_ sender: Any) {
        let textField = sender as? UITextField
        processInput(from: textField)
        if goalTextField.text != "" {
            print("HAHSHAH")
            goalTextField.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func goalCheckButtonTapped(_ sender: Any) {
        
        // TODO: Mark all corosponding tasks completed with this check.
        // TODO: Move to seperate function.
        if goal.completed == false {
            dataManager.updateOrDeleteGoal(goalID: goal.id, completed: true)
        } else {
            dataManager.updateOrDeleteGoal(goalID: goal.id, completed: false)
        }
        
        delegate?.cellChanged(at: indexPath, with: .fade)
    }
}
