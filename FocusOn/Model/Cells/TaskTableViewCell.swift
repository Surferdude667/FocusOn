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
        dataManager.delegate = self
    }
    
    func setTaskCheckMark() {
        if task.completed {
            taskCheckButton.backgroundColor = UIColor.green
        } else if task.title != "" {
            taskCheckButton.backgroundColor = UIColor.red
        } else {
            taskCheckButton.backgroundColor = UIColor.gray
            taskCheckButton.isUserInteractionEnabled = false
        }
    }
    
    // TODO: Mark goal completed if all tasks in that goal is checked.
    // TODO: Don't count the placeholder
    func updateTaskCheckMark() {
        
        var tasks = goal.tasks!.allObjects as! [Task]
        tasks.removeLast()
        var tasksCompleted = 0
    
        func numberOfCompletedTasks() {
            for task in tasks {
                if task.completed {
                    tasksCompleted += 1
                }
            }
        }
        
        if task.completed == false {
            dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, completed: true)
            numberOfCompletedTasks()
            
            if tasksCompleted == tasks.count {
                dataManager.updateOrDeleteGoal(goalID: goal.id, completed: true)
                delegate?.cellChanged(at: IndexPath(row: 0, section: indexPath.section), with: .fade)
            }
        } else {
            dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, completed: false)
            numberOfCompletedTasks()
            
            if tasksCompleted != tasks.count {
                dataManager.updateOrDeleteGoal(goalID: goal.id, completed: false)
                delegate?.cellChanged(at: IndexPath(row: 0, section: indexPath.section), with: .fade)
            }
        }
        delegate?.cellChanged(at: indexPath, with: .fade)
    }
    
    func processTextInput(from textField: UITextField?) {
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
                taskCheckButton.isUserInteractionEnabled = true
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
        processTextInput(from: textField)
        addNewEmptyTaskIfNone()
    }
    
    @IBAction func taskCheckButtonTapped(_ sender: Any) {
        updateTaskCheckMark()
    }
}
