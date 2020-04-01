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
    
    var goals = [Goal]()
    var tasks = [Task]()
    let dataManager = DataManager()
    
    
    //  MARK:- Configuration
    
    func configure() {
        tableView.delegate = self
        tableView.dataSource = self
        dataManager.delegate = self
        registerForKeyboardNotifications()
    }
    
    //MARK:- TableView Manipluation
    
    func reloadTableViewRow(at indexPath: IndexPath, with rowAnimation: UITableView.RowAnimation) {
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: rowAnimation)
        tableView.endUpdates()
    }
    
    func insertTableViewRow(at indexPath: IndexPath, with rowAnimation: UITableView.RowAnimation) {
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: rowAnimation)
        tableView.endUpdates()
    }
    
    func insertTableViewSection(with rowAnimation: UITableView.RowAnimation) {
        tableView.beginUpdates()
        tableView.insertSections(IndexSet(integer: tableView.numberOfSections), with: rowAnimation)
        tableView.endUpdates()
    }
    
    
    //  Adds an empty placeholder task cell if there is none.
    func addNewPlaceholderTaskIfNeeded() {
        for section in 0 ..< goals.count {
            var tasksInSection = goals[section].tasks?.allObjects as! [Task]
            tasksInSection.sort(by: { $0.id < $1.id })
            
            if tasksInSection.last?.title == "" { } else {
                let goalID = goals[section].id
                let indexPath = IndexPath(row: tasksInSection.count+1, section: section)
                
                dataManager.addNewEmptyTask(forGoal: goalID)
                insertTableViewRow(at: indexPath, with: .automatic)
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
    
    
    // MARK:- TableViewCell Delegates
    
    func goalTextFieldChangedForCell(cell: GoalTableViewCell, newCaption: String?, oldCaption: String?) {
        let cellSection = cell.indexPath?.section
        
        for section in 0..<tableView.numberOfSections {
            if (cellSection == section) && (newCaption != oldCaption) {
                
                if let goalID = cell.goal?.id {
                    dataManager.UpdateOrDeleteGoal(goalID: goalID, newTitle: newCaption, completed: nil, delete: false)
                    reloadTableViewRow(at: IndexPath(row: 0, section: section), with: .left)
                }
            }
        }
    }
    
    func taskTextFieldChangedForCell(cell: TaskTableViewCell, newCaption: String?, oldCaption: String?) {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                
                if (cell.indexPath == indexPath) && (oldCaption != newCaption) {
                    if let taskID = cell.task?.id {
                        if let goalID = cell.goal?.id {
                            dataManager.updateOrDeleteTask(taskID: taskID, goalID: goalID, newTitle: newCaption, completed: nil, delete: false)
                            reloadTableViewRow(at: indexPath, with: .left)
                        }
                    }
                }
            }
        }
        addNewPlaceholderTaskIfNeeded()
    }
    
    //  TODO: Mark all corosponding tasks completed with this check.
    func goalCheckMarkChangedForCell(cell: GoalTableViewCell) {
        let cellSection = cell.indexPath?.section
        
        for section in 0..<tableView.numberOfSections {
            if (cellSection == section) {
                if let goalID = cell.goal?.id {
                    
                    let goalWithCorrespondingID = goals.filter { $0.id == goalID }
                    if goalWithCorrespondingID.first!.completed == false {
                        dataManager.UpdateOrDeleteGoal(goalID: goalID, newTitle: nil, completed: true, delete: false)
                    } else {
                        dataManager.UpdateOrDeleteGoal(goalID: goalID, newTitle: nil, completed: false, delete: false)
                    }
                    
                    reloadTableViewRow(at: IndexPath(row: 0, section: section), with: .fade)
                }
            }
        }
    }
    
    //  TODO: Mark goal completed if all tasks in that goal is checked.
    func taskCheckMarkChangedForCell(cell: TaskTableViewCell) {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                
                let indexPath = IndexPath(row: row, section: section)
                
                if (cell.indexPath == indexPath) {
                    if cell.task!.completed == false {
                        dataManager.updateOrDeleteTask(taskID: cell.task!.id, goalID: cell.goal!.id, newTitle: nil, completed: true, delete: false)
                    } else {
                        dataManager.updateOrDeleteTask(taskID: cell.task!.id, goalID: cell.goal!.id, newTitle: nil, completed: false, delete: false)
                    }
                    reloadTableViewRow(at: indexPath, with: .fade)
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
        // TODO: Fix this unsafe unwrapping
        return goals[section].tasks!.count+1
    } 
    
    //  Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let firstRow = IndexPath(row: 0, section: indexPath.section)
        
        //  Set goal data
        if indexPath.row == 0 {
            let goal = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: firstRow) as! GoalTableViewCell
            goal.goalTextField.text = goals[indexPath.section].title
            goal.indexPath = indexPath
            goal.goal = goals[indexPath.section]
            goal.delegate = self
            
            if goals[indexPath.section].completed {
                goal.goalCheckButton.backgroundColor = UIColor.green
            } else {
                goal.goalCheckButton.backgroundColor = UIColor.red
            }
            
            return goal
        }
        //  Set task data
        else {
            let task = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
            var tasksInSection = goals[indexPath.section].tasks?.allObjects as! [Task]
            tasksInSection.sort(by: { $0.id < $1.id })
            let taskForRow = tasksInSection[indexPath.row-1]
            task.taskTextField.text = taskForRow.title
            task.task = taskForRow
            task.goal = goals[indexPath.section]
            task.indexPath = indexPath
            task.delegate = self
            
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
        if goals.count == 0 {
            dataManager.fetchAllGoals()
            dataManager.fetchAllTasks()
        }
    }
}

