//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class GoalCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: CellDelegate?
    var dataManager = DataManager()
    var indexPath: IndexPath!
    var oldCaption: String?
    var goal: Goal!
    
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var goalCheckButton: SpringButton!
    @IBOutlet weak var background: UIView!
    
    
    func configure() {
        goalTextField.delegate = self
        
    }
    
    
    func setGoalCheckMark() {
        if goal.completed {
            goalCheckButton.setImage(#imageLiteral(resourceName: "checkmark.pdf"), for: .normal)
            goalCheckButton.tintColor = #colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1)
            goalTextField.textColor = #colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1)
        } else {
            goalCheckButton.setImage(#imageLiteral(resourceName: "circle.pdf"), for: .normal)
            goalCheckButton.tintColor = #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)
            goalTextField.textColor = #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)
        }
    }
    
    
    func updateTaskGoalMark() {        
        if goal.completed == false {
            var tasks = goal.tasks!.allObjects as! [Task]
            tasks.removeLast()
            for task in tasks {
                dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, completed: true)
            }
            dataManager.updateOrDeleteGoal(goalID: goal.id, completed: true)
            delegate?.sectionChanged(at: indexPath, with: .middle)
        }
    }
    
    
    func processInput(from textField: UITextField?) {
        if let textField = textField {
            let newCaption = textField.text
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
    }
    
    @IBAction func goalCheckButtonTapped(_ sender: Any) {
        updateTaskGoalMark()
    }
}
