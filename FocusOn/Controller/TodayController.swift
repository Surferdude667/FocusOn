//
//  TodayController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 09/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import CoreData

class TodayController: UIViewController, UITableViewDataSource, UITableViewDelegate, TaskCellDelegate, GoalCellDelegate, DataManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let dataManager = DataManager()
    var goals = [Goal]()
    
    
    //  MARK:- Configuration
    
    func configure() {
        tableView.delegate = self
        tableView.dataSource = self
        dataManager.delegate = self
        registerForKeyboardNotifications()
    }
    
    //MARK:- TableView Manipluation
    
    func reloadTableViewRow(at indexPath: IndexPath, with rowAnimation: UITableView.RowAnimation) {
        tableView.reloadRows(at: [indexPath], with: rowAnimation)
    }
    
    func insertTableViewRow(at indexPath: IndexPath, with rowAnimation: UITableView.RowAnimation) {
        tableView.insertRows(at: [indexPath], with: rowAnimation)
    }
    
    func insertTableViewSection(with rowAnimation: UITableView.RowAnimation) {
        tableView.insertSections(IndexSet(integer: tableView.numberOfSections), with: rowAnimation)
    }
    
    func removeTableViewRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
        updateIndexPathForCells()
    }
    
    func removeTableViewSection(at section: Int) {
        tableView.deleteSections(IndexSet(integer: section), with: .bottom)
        updateIndexPathForCells()
    }
    
    
    //  Adds an empty placeholder task cell if there is none.
    func addNewPlaceholderTaskIfNeeded() {
        for section in 0..<tableView.numberOfSections {
            let numberOfRows = tableView.numberOfRows(inSection: section)
            
            if let lastCell = tableView.cellForRow(at: IndexPath(row: numberOfRows-1, section: section)) as? TaskTableViewCell {
                if lastCell.taskTextField.text != "" {
                    dataManager.addNewEmptyTask(forGoal: lastCell.goal.id)
                    insertTableViewRow(at: IndexPath(row: numberOfRows, section: section), with: .automatic)
                }
            }
        }
    }
    
    //  Add new empty section with 1 empty goal and 1 empty task
    func addNewGoal() {
        dataManager.addNewEmptyGoalAndTask()
        insertTableViewSection(with: .top)
        scrollToBottom()
    }
    
    func scrollToBottom() {
        let sections = tableView.numberOfSections-1
        let bottomRow = tableView.numberOfRows(inSection: sections)-1
        let bottomIndexPath = IndexPath(row: bottomRow, section: sections)
        tableView.scrollToRow(at: bottomIndexPath, at: .top, animated: true)
    }
    
    
    // MARK:- DELETE
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipeAction = UISwipeActionsConfiguration(actions: [editContextualAction(forRowAt: indexPath), deleteContextualAction(forRowAt: indexPath)])
        return swipeAction
    }
    
    func editContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") {
            (contextualAction: UIContextualAction, swipeButton: UIView, completionHandler: (Bool) -> Void) in
            
            print("Edit!")
            
            // Call true if edit succeded
            completionHandler(false)
        }
        
        action.backgroundColor = .magenta
        return action
    }
    
    // Delete action
    func deleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (contextualAction: UIContextualAction, swipeButton: UIView, completionHandler: (Bool) -> Void) in
            
            let goalCell = self.tableView.cellForRow(at: indexPath) as? GoalTableViewCell
            let taskCell = self.tableView.cellForRow(at: indexPath) as? TaskTableViewCell
            
            if indexPath.row == 0 {
                self.goals.remove(at: indexPath.section)
                self.dataManager.UpdateOrDeleteGoal(goalID: goalCell!.goal.id, newTitle: nil, completed: nil, delete: true)
                self.removeTableViewSection(at: indexPath.section)
            } else {
                self.dataManager.updateOrDeleteTask(taskID: taskCell!.task.id, goalID: taskCell!.goal.id, newTitle: nil, completed: nil, delete: true)
                self.removeTableViewRow(at: indexPath)
            }
            
            completionHandler(true)
        }
        
        action.backgroundColor = .magenta
        //action.image = .remove
        return action
    }
    
    
    // MARK:- TableViewCell Delegates
    
    func goalTextFieldChangedForCell(cell: GoalTableViewCell, newCaption: String?, oldCaption: String?) {
        if newCaption != oldCaption {
            dataManager.UpdateOrDeleteGoal(goalID: cell.goal.id, newTitle: newCaption, completed: nil, delete: false)
            reloadTableViewRow(at: IndexPath(row: 0, section: cell.indexPath!.section), with: .left)
        }
    }
    
    func taskTextFieldChangedForCell(cell: TaskTableViewCell, newCaption: String?, oldCaption: String?) {
        if oldCaption != newCaption {
            dataManager.updateOrDeleteTask(taskID: cell.task.id, goalID: cell.goal.id, newTitle: newCaption, completed: nil, delete: false)
            reloadTableViewRow(at: cell.indexPath!, with: .left)
            addNewPlaceholderTaskIfNeeded()
        }
    }
    
    //  TODO: Mark all corosponding tasks completed with this check.
    func goalCheckMarkChangedForCell(cell: GoalTableViewCell) {
        let goalID = cell.goal.id
        let goalWithCorrespondingID = goals.filter { $0.id == goalID }.first!
        
        if goalWithCorrespondingID.completed == false {
            dataManager.UpdateOrDeleteGoal(goalID: goalID, newTitle: nil, completed: true, delete: false)
        } else {
            dataManager.UpdateOrDeleteGoal(goalID: goalID, newTitle: nil, completed: false, delete: false)
        }
        
        reloadTableViewRow(at: IndexPath(row: 0, section: cell.indexPath!.section), with: .fade)
    }
    
    
    //  TODO: Mark goal completed if all tasks in that goal is checked.
    func taskCheckMarkChangedForCell(cell: TaskTableViewCell) {
        if cell.task.completed == false {
            dataManager.updateOrDeleteTask(taskID: cell.task.id, goalID: cell.goal.id, newTitle: nil, completed: true, delete: false)
        } else {
            dataManager.updateOrDeleteTask(taskID: cell.task.id, goalID: cell.goal.id, newTitle: nil, completed: false, delete: false)
        }
        reloadTableViewRow(at: IndexPath(row: cell.indexPath!.row, section: cell.indexPath!.section), with: .fade)
    }
    
    
    //  Updates the indexPath propaty on all available cells in tableView.
    func updateIndexPathForCells() {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                let cell = tableView.cellForRow(at: indexPath)
                
                if indexPath.row == 0 {
                    if let goal = cell as? GoalTableViewCell {
                        goal.indexPath = indexPath
                    }
                } else {
                    if let task = cell as? TaskTableViewCell {
                        task.indexPath = indexPath
                    }
                }
            }
        }
    }
    
    
    //  MARK:- TableView Delegates
    
    //  Return the number of sections in table.
    func numberOfSections(in tableView: UITableView) -> Int {
        return goals.count
    }
    
    //  Return the number of rows for the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfRows = goals[section].tasks {
            return numberOfRows.count+1
        }
        return 0
    }
    
    //  Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let firstRow = IndexPath(row: 0, section: indexPath.section)
        
        //  Set goal data in first row.
        if indexPath.row == 0 {
            let goal = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: firstRow) as! GoalTableViewCell
            goal.goalTextField.text = goals[indexPath.section].title
            goal.indexPath = indexPath
            goal.goal = goals[indexPath.section]
            goal.delegate = self
            
            // TODO: Move this to the cell instead (If possible).
            if goals[indexPath.section].completed {
                goal.goalCheckButton.backgroundColor = UIColor.green
            } else {
                goal.goalCheckButton.backgroundColor = UIColor.red
            }
            
            return goal
        }
            //  Set task data in remaining rows.
        else {
            let task = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
            let tasksInSection = goals[indexPath.section].tasks?.allObjects as! [Task]
            let taskForRow = tasksInSection[indexPath.row-1]
            task.taskTextField.text = taskForRow.title
            task.task = taskForRow
            task.goal = goals[indexPath.section]
            task.indexPath = indexPath
            task.delegate = self
            
            // TODO: Move this to the cell instead (If possible).
            if taskForRow.completed {
                task.taskCheckButton.backgroundColor = UIColor.green
            } else {
                task.taskCheckButton.backgroundColor = UIColor.red
            }
            
            return task
        }
    }
    
    
    //  MARK:- Keyboard handling
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 49.0
        adjustLayoutForKeyboard(targetHeight: keyboardFrame.size.height - tabBarHeight)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        adjustLayoutForKeyboard(targetHeight: 0)
    }
    
    func adjustLayoutForKeyboard(targetHeight: CGFloat) {
        tableView.contentInset.bottom = targetHeight
    }
    
    //  MARK:- Actions
    
    //  TODO: Prevent this if there is alrady an empty goal.
    //  TODO: Automaticly set the cursor in the new field.
    @IBAction func addNewGoalButton(_ sender: Any) {
        addNewGoal()
        
        // DEMO
        for objects in goals {
            print("Goal: \(objects.title) ID: \(objects.id)")
            
            let tasks = objects.tasks?.allObjects as! [Task]
            for element in tasks {
                print("Task: \(element.title) ID: \(element.id)")
            }
        }
    }
    
    //  MARK:- ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Look at this!
        // Load today goals only. (On date).
        // If no today goals available.
        // Load yestadays goals.
        // If any uncompleted goals, ask user if they should be transfered to today.
        // If yes, change date to today on those goals.
        // Reload today.
        // If user says no, do nothing. (Will keep asking until there is any goal on today).
        // If no yestaday do nothing.
        // Present empy tableview ready to add goals for the day.
        if goals.count == 0 {
            dataManager.fetchAllGoals()
        }
    }
}
