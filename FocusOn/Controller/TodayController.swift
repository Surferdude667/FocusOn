//
//  TodayController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 09/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class TodayController: UIViewController, UITableViewDataSource, UITableViewDelegate, TaskCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //  TODO: Move the data out of controller. (CoreData).
    var goalCollection = [DataStructure(goal: "Goal 1", task: ["Task 1 (1)", "Task 2 (1)", "Task 3 (1)", ""]),
                          DataStructure(goal: "Goal 2", task: ["Task 1 (2)", "Task 2 (2)", "Task 3 (2)", "Task 4 (2)", "Task 5 (2)", ""]),
                          DataStructure(goal: "Goal 3", task: ["Task 1 (3)", "Task 2 (3)", "Task 3 (3)", ""])]
    
    
    //  MARK:- Configuration
    
    func configure() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //  TODO: If a cell is empty "" and not the last. Delete it.
    //  Adds an empty placeholder task cell if there is none.
    func addPlaceholderTask() {
        for section in 0 ..< goalCollection.count {
            if goalCollection[section].task.last == "" {
            } else {
                goalCollection[section].task.append("")
                let indexPath = IndexPath(row: goalCollection[section].task.count, section: section)
                tableView.beginUpdates()
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    
    //  MARK:- TableView
    
    func taskTextFieldChangedForCell(cell: TaskTableViewCell, newCaption: String?, oldCaption: String?) {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                
                let indexPath = IndexPath(row: row, section: section)
                
                if (cell.indexPath == indexPath) && (oldCaption != newCaption) {
                    goalCollection[section].task[row-1] = newCaption
                    
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: .left)
                    tableView.endUpdates()
                }
            }
        }
        addPlaceholderTask()
    }

    
    
    //  Return the number of sections in table.
    func numberOfSections(in tableView: UITableView) -> Int {
        return goalCollection.count
    }
    
    //  Return the number of rows for the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goalCollection[section].task.count + 1
    } 
    
    //  Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let firstRow = IndexPath(row: 0, section: indexPath.section)
        let taskIndex = indexPath.row-1
        
        //  Set goal data
        if indexPath.row == 0 {
            let goal = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: firstRow) as! GoalTableViewCell
            if let goalForSection = goalCollection[indexPath.section].goal {
                goal.goalTextField.text = goalForSection
                return goal
            }
        }
        //  Set task data
        else {
            let task = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
            if let taskForRow = goalCollection[indexPath.section].task[taskIndex] {
                task.taskTextField.text = taskForRow
                task.indexPath = indexPath
                task.delegate = self
                return task
            }
        }
        return UITableViewCell()
    }
    
    //  Adjust section height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    @IBAction func addTaskButton(_ sender: Any) {
        
    }
    
    //  MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

