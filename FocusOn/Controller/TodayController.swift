//
//  TodayController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 09/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import CoreData

class TodayController: UIViewController, UITableViewDataSource, UITableViewDelegate, TaskCellDelegate, GoalCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var goals = [NSManagedObject]()
    
    
    //  TODO: Move the data out of controller. (CoreData).
    var todayTodos = [DataModel(goal: "Goal 1", tasks: ["Task 1 (1)", "Task 2 (1)", "Task 3 (1)", ""]),
                          DataModel(goal: "Goal 2", tasks: ["Task 1 (2)", "Task 2 (2)", "Task 3 (2)", "Task 4 (2)", "Task 5 (2)", ""]),
                          DataModel(goal: "Goal 3", tasks: ["Task 1 (3)", "Task 2 (3)", "Task 3 (3)", ""])]
    
    
    
    func save(goal: DataModel) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Goal", in: managedContext)!
        let goalObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        goalObject.setValue(goal.goal, forKey: "goal")
        goalObject.setValue(goal.tasks, forKey: "tasks")
        
        do {
            try managedContext.save()
            goals.append(goalObject)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func fetch() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Goal")
        
        do {
            goals = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    //  MARK:- Configuration
    
    func configure() {
        tableView.delegate = self
        tableView.dataSource = self
        registerForKeyboardNotifications()
    }
    
    //MARK:- TableView Manipluation
    
    //  TODO: If a cell is empty "" and not the last. Delete it.
    //  Adds an empty placeholder task cell if there is none.
    func addPlaceholderTask() {
        for section in 0 ..< todayTodos.count {
            if todayTodos[section].tasks.last == "" {
            } else {
                todayTodos[section].tasks.append("")
                let indexPath = IndexPath(row: todayTodos[section].tasks.count, section: section)
                tableView.beginUpdates()
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    
    //  Add new empty section with 1 empty goal and 1 empty task
    func addNewGoal() {
        let sections = tableView.numberOfSections
        let newGoal = DataModel(goal: "", tasks: [""])
        todayTodos.append(newGoal)
        
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
                todayTodos[section].goal = newCaption
                
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
                    todayTodos[section].tasks[row-1] = newCaption
                    
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
        return todayTodos.count
    }
    
    //  Return the number of rows for the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayTodos[section].tasks.count + 1
    } 
    
    //  Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let firstRow = IndexPath(row: 0, section: indexPath.section)
        let taskIndex = indexPath.row-1
        
        //  Set goal data
        if indexPath.row == 0 {
            let goal = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: firstRow) as! GoalTableViewCell
            if let goalForSection = todayTodos[indexPath.section].goal {
                goal.goalTextField.text = goalForSection
                goal.indexPath = indexPath
                goal.delegate = self
                return goal
            }
        }
            //  Set task data
        else {
            let task = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
            if let taskForRow = todayTodos[indexPath.section].tasks[taskIndex] {
                task.taskTextField.text = taskForRow
                task.indexPath = indexPath
                task.delegate = self
                return task
            }
        }
        return UITableViewCell()
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
        save(goal: todayTodos[0])
        
        for i in 0..<goals.count {
            print(goals[i].value(forKey: "tasks") as! [String])
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
        //fetch()
    }
}

