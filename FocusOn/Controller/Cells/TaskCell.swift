//
//  TaskTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell, UITextFieldDelegate, DataManagerDelegate {
    
    var dataManager = DataManager()
    var goals = [Goal]()
    var delegate: CellDelegate?
    var indexPath: IndexPath!
    var oldCaption: String?
    var task: Task!
    var goal: Goal!
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var taskCheckButton: SpringButton!
    @IBOutlet weak var background: GradientView!
    
    func configure() {
        taskTextField.delegate = self
        dataManager.delegate = self
    }
    
    func setTaskCheckMark() {
        if task.completed && task.title != "" {
            background.firstColor = #colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1)
            background.secondColor = #colorLiteral(red: 0.9450980392, green: 0.8666666667, blue: 0.6, alpha: 1)
            taskCheckButton.setImage(#imageLiteral(resourceName: "checkmark.pdf"), for: .normal)
            taskCheckButton.isUserInteractionEnabled = true
        } else if task.completed == false && task.title != "" {
            background.firstColor = #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)
            background.secondColor = #colorLiteral(red: 0.9450980392, green: 0.8666666667, blue: 0.6, alpha: 1)
            taskCheckButton.setImage(#imageLiteral(resourceName: "circle.pdf"), for: .normal)
            taskCheckButton.isUserInteractionEnabled = true
        } else {
            background.firstColor = #colorLiteral(red: 0.2039999962, green: 0.2039999962, blue: 0.2039999962, alpha: 1)
            background.secondColor = #colorLiteral(red: 0.2039999962, green: 0.2039999962, blue: 0.2039999962, alpha: 1)
            taskCheckButton.setImage(#imageLiteral(resourceName: "plus.pdf"), for: .normal)
            taskCheckButton.isUserInteractionEnabled = false
        }
    }
    
    func checkAndUpdateGroupCompletion() {
        var tasks = goal.tasks!.allObjects as! [Task]
        tasks.removeLast()
        var tasksCompleted = 0
        
        for task in tasks {
            if task.completed {
                tasksCompleted += 1
            }
        }
        
        if tasksCompleted == tasks.count && goal.completed == false {
            dataManager.updateOrDeleteGoal(goalID: goal.id, completed: true)
            delegate?.cellChanged(at: IndexPath(row: 0, section: indexPath.section), with: .fade)
            // TODO: Make delegate success message with Goal title included.
            
            print("HURAAA")
        }
        
        if tasksCompleted != tasks.count && goal.completed == true {
            dataManager.updateOrDeleteGoal(goalID: goal.id, completed: false)
            delegate?.cellChanged(at: IndexPath(row: 0, section: indexPath.section), with: .fade)
        }
    }
    
    func updateTaskCheckMark() {
        if task.completed == false {
            dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, completed: true)
            checkAndUpdateGroupCompletion()
        } else {
            dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, completed: false)
            checkAndUpdateGroupCompletion()
        }
        
        delegate?.cellChanged(at: indexPath, with: .fade)
    }
    
    func processTextInput(from textField: UITextField?) {
        if let textField = textField {
            let newCaption = textField.text
            
            if oldCaption != newCaption {
                dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, newTitle: newCaption)
                delegate?.cellChanged(at: indexPath, with: .left)
                taskCheckButton.isUserInteractionEnabled = true
            }
        }
    }
    
    
    func addNewEmptyTaskIfNone() {
        if let lastTask = goal.tasks?.allObjects.last as? Task {
            if lastTask.title != "" {
                let index = IndexPath(row: indexPath.row+1, section: indexPath.section)
                dataManager.addNewEmptyTask(forGoal: lastTask.goal.id)
                delegate?.cellAdded(at: index, with: .top)
                checkAndUpdateGroupCompletion()
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
            oldCaption = textField.text
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
