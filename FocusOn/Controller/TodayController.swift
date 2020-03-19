//
//  ViewController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 09/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class TodayController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [DataStructure(section: 0, goal: "Goal1", task: ["Task 1", "Task 2", "Task 3"]),
                DataStructure(section: 1, goal: "Goal2", task: ["Task 11", "Task 22", "Task 33", "Task 44"]),
                DataStructure(section: 0, goal: "Goal4", task: ["Task 14", "Task 24", "Task 34"])]
    
    
    //  MARK:- Configuration
    
    func configure() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //  MARK:- TableView
    
    //  Return the number of sections in table.
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    //  Return the number of rows for the section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].task.count + 1
    }
    
    //  Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let section = data[indexPath.section].section {
            let firstRow = IndexPath(row: 0, section: section)
            let taskIndex = indexPath.row-1
            
            //  Set goal data
            if indexPath.row == 0 {
                let goal = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: firstRow)
                goal.textLabel?.text = data[indexPath.section].goal
                return goal
            }
            //  Set task data
            else {
                let task = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
                task.textLabel?.text = data[indexPath.section].task[taskIndex]
                return task
            }
        }
        return UITableViewCell()
    }
    
    //  Adjust section height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    //  MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

