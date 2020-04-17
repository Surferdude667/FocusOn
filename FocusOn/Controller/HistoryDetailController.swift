//
//  ViewController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 11/04/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class HistoryDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var goal: Goal!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tasks = goal.tasks?.allObjects {
            return tasks.count
        }
        return 0
     }
     
        
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let goal = tableView.dequeueReusableCell(withIdentifier: "detailGoalCell", for: indexPath) as! DetailGoalCell
            goal.goalTitleLabel.text = self.goal.title
            goal.goal = self.goal
            goal.setGoalCheckMark()
            return goal
        default:
            if let tasks = goal.tasks?.allObjects as? [Task] {
                let task = tableView.dequeueReusableCell(withIdentifier: "detailTaskCell", for: indexPath) as! DetailTaskCell
                task.taskTitleLabel.text = tasks[indexPath.row - 1].title
                task.task = tasks[indexPath.row - 1]
                task.setTaskCheckMark()
                return task
            }
        }
        
        return UITableViewCell()
     }
    
    
    func configure() {
        tableView.delegate = self
        tableView.dataSource = self
        overrideUserInterfaceStyle = .dark
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    

}
