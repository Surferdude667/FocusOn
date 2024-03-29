//
//  Created by Bjørn Lau Jørgensen on 09/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import UserNotifications

class TodayController: UIViewController, UITableViewDataSource, UITableViewDelegate, DataManagerDelegate, CellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewGoalButton: UIButton!
    
    let dataManager = DataManager()
    let timeManager = TimeManager()
    let statsManager = StatsManager()
    var yesterdaysUncompletedGoals = [Goal]()
    let userNotificationCenter = UNUserNotificationCenter.current()
    var goals = [Goal]()
    
    
    //  MARK:- Configuration
    
    func configure() {
        overrideUserInterfaceStyle = .dark
        tableView.delegate = self
        tableView.dataSource = self
        dataManager.delegate = self
        registerForKeyboardNotifications()
        requestNotificationAuthorization()
        createNotification()
        setStatusBar()
    }
    
    func manageAddButton() {
        if goals.last?.title == "" {
            addNewGoalButton.tintColor = UIColor.gray
            addNewGoalButton.setTitleColor(UIColor.gray, for: .normal)
            addNewGoalButton.isUserInteractionEnabled = false
        } else {
            addNewGoalButton.tintColor = UIColor.white
            addNewGoalButton.setTitleColor(UIColor.white, for: .normal)
            addNewGoalButton.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - User Notifications

    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }

    func createNotification() {
        let notificationContent = UNMutableNotificationContent()
        var body = ""
            
        if let stats = statsManager.createStats(from: dataManager.fetchGoals(from: timeManager.today), tasksOnly: false) {
            body = "Keep going! \(stats.completed) completed already! \(stats.uncompleted) to go!"
        } else {
            body = "Time to set some goals for the day?"
        }
        
        notificationContent.title = "Good morning!"
        notificationContent.body = body
        
        let timedTrigger = UNCalendarNotificationTrigger(dateMatching: timeManager.notificationTime(), repeats: false)
        let timedRequest = UNNotificationRequest(identifier: "notification", content: notificationContent, trigger: timedTrigger)
        
        userNotificationCenter.add(timedRequest) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    
    //MARK:- TableView Manipluation
    
    // Add new empty section with 1 empty goal and 1 empty task
    func addNewGoal() {
        _ = dataManager.addNewEmptyGoalAndTask()
        tableView.insertSections(IndexSet(integer: tableView.numberOfSections), with: .top)
        scrollToBottom()
        manageAddButton()
    }
    
    func scrollToBottom() {
        let sections = tableView.numberOfSections-1
        let bottomRow = tableView.numberOfRows(inSection: sections)-1
        let bottomIndexPath = IndexPath(row: bottomRow, section: sections)
        
        let newGoal = tableView.cellForRow(at: IndexPath(row: 0, section: bottomIndexPath.section)) as? GoalCell
        if let newGoal = newGoal {
            newGoal.goalTextField.becomeFirstResponder()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.scrollToRow(at: bottomIndexPath, at: .top, animated: true)
        }
    }
    
    func updateChart(section: Int) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? GoalCell
        if let cell = cell {
             cell.setChartData(animated: true)
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
                    if let goal = cell as? GoalCell { goal.indexPath = indexPath }
                } else {
                    if let task = cell as? TaskCell { task.indexPath = indexPath }
                }
            }
        }
    }
    
    
    // MARK:- Swipe actions
    
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
            
            let goalCell = self.tableView.cellForRow(at: indexPath) as? GoalCell
            let taskCell = self.tableView.cellForRow(at: indexPath) as? TaskCell
            
            if indexPath.row == 0 {
                let alertController = UIAlertController(title: "Are you sure?", message: "All corosponding tasks will also be deleted.", preferredStyle: .alert)
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
                self.updateChart(section: indexPath.section)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    taskCell?.checkAndUpdateGroupCompletion()
                }
            }
            self.updateIndexPathForCells()
            completionHandler(true)
        }
        
        action.backgroundColor = .black
        action.image = .remove
        return action
    }
    
    
    // MARK:- CellDelegate
    
    func sectionChanged(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: animation)
        manageAddButton()
        createNotification()
        updateChart(section: indexPath.section)
    }
    
    func cellChanged(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        tableView.reloadRows(at: [indexPath], with: animation)
        manageAddButton()
        createNotification()
        updateChart(section: indexPath.section)
        
        let cell = tableView.cellForRow(at: indexPath) as? TaskCell
        
        if let cell = cell {
            cell.taskCheckButton.animation = "pop"
            cell.taskCheckButton.curve = "spring"
            cell.taskCheckButton.animate()
        }
    }
    
    func cellAdded(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        tableView.insertRows(at: [indexPath], with: animation)
        manageAddButton()
        createNotification()
        updateChart(section: indexPath.section)
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
            let goal = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as! GoalCell
            goal.goalTextField.text = goals[indexPath.section].title
            goal.indexPath = indexPath
            goal.goal = goals[indexPath.section]
            goal.setGoalCheckMark()
            goal.setChartData(animated: false)
            goal.delegate = self
            return goal
        }
            //  Set task data in remaining rows.
        else {
            let task = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.tintColor = #colorLiteral(red: 0.02745098039, green: 0.03529411765, blue: 0.0431372549, alpha: 1)
    }
    
    // MARK:- Dataloading
    
    // TODO: Some if this could maybe be moved out of the ViewController.
    func askToTransferYesterdaysGoals() {
        let alertController = UIAlertController(title: "Unfinished tasks", message: "Want to transfer from yesterday?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .destructive)
        let transferAction = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
            
            for goal in self.yesterdaysUncompletedGoals {
                self.dataManager.updateOrDeleteGoal(goalID: goal.id, newCreation: self.timeManager.today)
            }
            
            self.goals = self.dataManager.fetchGoals(from: self.timeManager.today)
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
            goals = dataManager.fetchGoals(from: timeManager.today)
            
            // If no goals found for today. Fetch yesterday.
            if goals.count == 0 {
                let yesterdays = dataManager.fetchGoals(from: timeManager.yesterday)
                
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
    
    func setStatusBar() {
        let statusBarFrame = UIApplication.shared.statusBarFrame
        let statusBarView = UIView(frame: statusBarFrame)
        self.view.addSubview(statusBarView)
        statusBarView.backgroundColor = #colorLiteral(red: 0.02745098039, green: 0.03529411765, blue: 0.0431372549, alpha: 1)
    }
    
    //  MARK:- Actions
    
    @IBAction func addNewGoalButton(_ sender: Any) {
        addNewGoal()
    }
    
    //  MARK:- ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

    
        // ****** DEMO ****** //
        // DemoManager().populateDemoData()
        // ****** DEMO ****** //
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
