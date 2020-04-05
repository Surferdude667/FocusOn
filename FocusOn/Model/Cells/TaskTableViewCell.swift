//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell, UITextFieldDelegate, DataManagerDelegate {
    
    var dataManager = DataManager()
    var goals = [Goal]()
    var delegate: CellDelegate?
    var indexPath: IndexPath!
    var oldCaption: String?
    var task: Task!
    var goal: Goal!
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var taskCheckButton: UIButton!
    
    func configure() {
        taskTextField.delegate = self
        //dataManager.delegate = self
    }
    
    func setTaskCheckMark() {
        if task.completed {
            taskCheckButton.backgroundColor = UIColor.green
        } else {
            taskCheckButton.backgroundColor = UIColor.red
        }
    }
    
    func processInput(from textField: UITextField?) {
        if let textField = textField {
            let newCaption = CellFunctions().fetchInput(textField: textField)
            
            if oldCaption != newCaption {
                dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, newTitle: newCaption)
                delegate?.cellChanged(at: indexPath, with: .left)
            }
        }
    }
    
    
    func addNewEmptyTaskIfNone() {
        if let lastTask = goal.tasks?.allObjects.last as? Task {
            if lastTask.title != "" {
                let index = IndexPath(row: indexPath.row+1, section: indexPath.section)
                dataManager.addNewEmptyTask(forGoal: lastTask.goal.id)
                delegate?.cellAdded(at: index, with: .top)
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
    
    
    @IBAction func taskEditBegun(_ sender: Any) {
        let textField = sender as? UITextField
        if let textField = textField {
            oldCaption = CellFunctions().fetchInput(textField: textField)
        }
    }
    
    @IBAction func taskEditEnded(_ sender: Any) {
        let textField = sender as? UITextField
        processInput(from: textField)
        addNewEmptyTaskIfNone()
    }
    
    @IBAction func taskCheckButtonTapped(_ sender: Any) {
        //taskTextField.isUserInteractionEnabled = false
        
        // TODO: Mark goal completed if all tasks in that goal is checked.
        // TODO: Move to seperate function
        if task.completed == false {
            dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, completed: true)
        } else {
            dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, completed: false)
        }
        
        delegate?.cellChanged(at: indexPath, with: .fade)
    }
}
