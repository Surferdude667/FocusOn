//
//  Created by Bjørn Lau Jørgensen on 09/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class TodayController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataManagerDelegate, CellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewGoalButton: UIButton!
    
    let dataManager = DataManager()
    let timeManager = TimeManager()
    var yesterdaysUncompletedGoals = [Goal]()
    var goals = [Goal]()
    
    
    //  MARK:- Configuration
    
    func configure() {
        tableView.delegate = self
        tableView.dataSource = self
        dataManager.delegate = self
        registerForKeyboardNotifications()
    }
    
    func manageAddButton() {
        if goals.last?.title == "" {
            addNewGoalButton.backgroundColor = UIColor.gray
            addNewGoalButton.isUserInteractionEnabled = false
        } else {
            addNewGoalButton.backgroundColor = UIColor.green
            addNewGoalButton.isUserInteractionEnabled = true
        }
    }
    
    //MARK:- TableView Manipluation
    
    // Add new empty section with 1 empty goal and 1 empty task
    func addNewGoal() {
        dataManager.addNewEmptyGoalAndTask()
        tableView.insertSections(IndexSet(integer: tableView.numberOfSections), with: .top)
        scrollToBottom()
        manageAddButton()
    }
    
    func scrollToBottom() {
        let sections = tableView.numberOfSections-1
        let bottomRow = tableView.numberOfRows(inSection: sections)-1
        let bottomIndexPath = IndexPath(row: bottomRow, section: sections)
        
        let newGoal = tableView.cellForRow(at: IndexPath(row: 0, section: bottomIndexPath.section)) as! GoalTableViewCell
        newGoal.goalTextField.becomeFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.scrollToRow(at: bottomIndexPath, at: .top, animated: true)
        }
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
    
    
    func deleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (contextualAction: UIContextualAction, swipeButton: UIView, completionHandler: (Bool) -> Void) in
            
            let goalCell = self.tableView.cellForRow(at: indexPath) as? GoalTableViewCell
            let taskCell = self.tableView.cellForRow(at: indexPath) as? TaskTableViewCell
            
            if indexPath.row == 0 {
                let alertController = UIAlertController(title: "Delete whole section?", message: "Make sure lalal...", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action:UIAlertAction) in
                    self.goals.remove(at: indexPath.section)
                    self.dataManager.updateOrDeleteGoal(goalID: goalCell!.goal.id, delete: true)
                    self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                    self.manageAddButton()
                }

                alertController.addAction(cancelAction)
                alertController.addAction(deleteAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.dataManager.updateOrDeleteTask(taskID: taskCell!.task.id, goalID: taskCell!.goal.id, delete: true)
                self.tableView.deleteRows(at: [indexPath], with: .none)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    taskCell?.checkAndUpdateGroupCompletion()
                }
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
        manageAddButton()
    }
    
    func cellChanged(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        tableView.reloadRows(at: [indexPath], with: animation)
        manageAddButton()
    }
    
    func cellAdded(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        tableView.insertRows(at: [indexPath], with: animation)
        manageAddButton()
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
            task.setTaskCheckMark()
            task.delegate = self
            return task
        }
    }
    
    // MARK:- Dataloading
    
    // TODO: Some if this could maybe be moved out of the ViewController.
    func askToTransferYesterdaysGoals() {
        let alertController = UIAlertController(title: "Unfinished tasks", message: "Want to transfer from yesterday?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .destructive)
        let transferAction = UIAlertAction(title: "Yes", style: .cancel) { (action:UIAlertAction) in
            
            for goal in self.yesterdaysUncompletedGoals {
                self.dataManager.updateOrDeleteGoal(goalID: goal.id, newCreation: self.timeManager.today)
            }
            
            self.goals = self.dataManager.fetchGoals(date: self.timeManager.today)
            self.tableView.reloadData()
            self.yesterdaysUncompletedGoals.removeAll()
            self.manageAddButton()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(transferAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func fetchTodayGoals() {
        // Fetch goals for today.
        if goals.count == 0 {
            goals = dataManager.fetchGoals(date: timeManager.today)
            
            // If no goals found for today. Fetch yesterday.
            if goals.count == 0 {
                let yesterdays = dataManager.fetchGoals(date: timeManager.yesterday)
                
                // If any of yesterdays goals is uncompleted append them.
                if yesterdays.count != 0 {
                    for goal in yesterdays {
                        if goal.completed == false {
                            yesterdaysUncompletedGoals.append(goal)
                        }
                    }
                }
            }
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
    
    @IBAction func addNewGoalButton(_ sender: Any) {
        addNewGoal()
    }
    
    //  MARK:- UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
//        print("Today: \(timeManager.today)")
//        print("Yesterday: \(timeManager.yesterday)")
//
//        print("Today: \(timeManager.formattedDate(for: timeManager.today))")
//        print("Yesterday: \(timeManager.formattedDate(for: timeManager.yesterday))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if yesterdaysUncompletedGoals.count != 0 {
            askToTransferYesterdaysGoals()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchTodayGoals()
        manageAddButton()
    }
}
