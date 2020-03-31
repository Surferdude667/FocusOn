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
        registerForKeyboardNotifications()
        dataManager.delegate = self
    }
    
    //MARK:- TableView Manipluation
    
    //  TODO: If a cell is empty "" and not the last. Delete it.
    //  Adds an empty placeholder task cell if there is none.
    func addPlaceholderTask() {
        for section in 0 ..< goals.count {
            
            var tasksInSection = goals[section].tasks?.allObjects as! [Task]
            tasksInSection.sort(by: { $0.id < $1.id })
            
            if tasksInSection.last?.title == "" {

            } else {
                let goalID = goals[section].id
                dataManager.addNewEmptyTask(forGoal: goalID)
                
                let indexPath = IndexPath(row: tasksInSection.count+1, section: section)
                tableView.beginUpdates()
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    
    //  Add new empty section with 1 empty goal and 1 empty task
    func addNewGoal() {
        let sections = tableView.numberOfSections
        
        dataManager.addNewEmptyGoal()
        
        tableView.beginUpdates()
        tableView.insertSections(IndexSet(integer: sections), with: .top)
        tableView.endUpdates()
        
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
                }
                
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: 0, section: section)], with: .left)
                tableView.endUpdates()
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
                            dataManager.updateOrDeleteTask(taskID: Int(taskID), goalID: goalID, newTitle: newCaption, completed: nil, delete: false)
                        }
                    }
                    
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: .left)
                    tableView.endUpdates()
                }
            }
        }
        addPlaceholderTask()
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
            return task
        }
        //return UITableViewCell()
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
    
    
    @IBAction func addNewGoalButton(_ sender: Any) {
        addNewGoal()
                
        for objects in goals {
            print("\(objects.title) ID: \(objects.id)")
            
            let tasks = objects.tasks?.allObjects as! [Task]
            for element in tasks {
                print(element.title, element.id)
            }
        }
        
    }
    
    //  MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //  MARK- viewWillApear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataManager.fetchAllGoals()
        dataManager.fetchAllTasks()
    }
}

