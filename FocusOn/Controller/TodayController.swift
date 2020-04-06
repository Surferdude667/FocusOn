//
//  Created by Bjørn Lau Jørgensen on 09/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class TodayController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataManagerDelegate, CellDelegate {

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
    
    // Add new empty section with 1 empty goal and 1 empty task
    func addNewGoal() {
        dataManager.addNewEmptyGoalAndTask()
        tableView.insertSections(IndexSet(integer: tableView.numberOfSections), with: .top)
        scrollToBottom()
    }
    
    func scrollToBottom() {
        let sections = tableView.numberOfSections-1
        let bottomRow = tableView.numberOfRows(inSection: sections)-1
        let bottomIndexPath = IndexPath(row: bottomRow, section: sections)
        tableView.scrollToRow(at: bottomIndexPath, at: .top, animated: true)
    }
    
    //  Updates the indexPath property on all available cells in the TableView.
    //  This needs to be performed after any type of deletion in the TabelView.
    func updateIndexPathForCells() {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                let cell = tableView.cellForRow(at: indexPath)
                
                if indexPath.row == 0 {
                    if let goal = cell as? GoalTableViewCell { goal.indexPath = indexPath }
                } else {
                    if let task = cell as? TaskTableViewCell { task.indexPath = indexPath }
                }
            }
        }
    }
    
    
    // MARK:- SWIPE ACTIONS
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let lastRow = tableView.numberOfRows(inSection: indexPath.section)-1
        if indexPath.row != lastRow {
            let swipeAction = UISwipeActionsConfiguration(actions: [deleteContextualAction(forRowAt: indexPath)])
            return swipeAction
        }
        return nil
    }
    
    
    // Delete action
    func deleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (contextualAction: UIContextualAction, swipeButton: UIView, completionHandler: (Bool) -> Void) in
            
            let goalCell = self.tableView.cellForRow(at: indexPath) as? GoalTableViewCell
            let taskCell = self.tableView.cellForRow(at: indexPath) as? TaskTableViewCell
            
            if indexPath.row == 0 {
                // TODO: Present alert controller to confirm deletion.
                self.goals.remove(at: indexPath.section)
                self.dataManager.updateOrDeleteGoal(goalID: goalCell!.goal.id, delete: true)
                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            } else {
                self.dataManager.updateOrDeleteTask(taskID: taskCell!.task.id, goalID: taskCell!.goal.id, delete: true)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            self.updateIndexPathForCells()
            completionHandler(true)
        }
        
        action.backgroundColor = .red
        //action.image = .remove
        return action
    }
    
    
    // MARK:- CellDelegate
    
    func sectionChanged(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: animation)
    }
    
    func cellChanged(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        tableView.reloadRows(at: [indexPath], with: animation)
    }
    
    func cellAdded(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        tableView.insertRows(at: [indexPath], with: animation)
    }
    
    
    //  MARK:- TableView delegates
    
    //  Return the number of sections in table.
    func numberOfSections(in tableView: UITableView) -> Int {
        return goals.count
    }
    
    //  Return the number of rows for the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfRows = goals[section].tasks { return numberOfRows.count + 1 }
        return 0
    }
    
    //  Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //  Set goal data in first row.
        if indexPath.row == 0 {
            let goal = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as! GoalTableViewCell
            goal.goalTextField.text = goals[indexPath.section].title
            goal.indexPath = indexPath
            goal.goal = goals[indexPath.section]
            goal.setGoalCheckMark()
            goal.delegate = self
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
            task.setTaskCheckMark()
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
//        for objects in goals {
//            print("Goal: \(objects.title) ID: \(objects.id)")
//
//            let tasks = objects.tasks?.allObjects as! [Task]
//            for element in tasks {
//                print("Task: \(element.title) ID: \(element.id)")
//            }
//        }
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
