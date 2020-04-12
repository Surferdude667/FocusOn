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
            return tasks.count + 1
        }
        return 0
     }
     
        
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let goal = tableView.dequeueReusableCell(withIdentifier: "detailGoalCell", for: indexPath)
            goal.textLabel?.text = self.goal.title
            return goal
        default:
            if let tasks = goal.tasks?.allObjects as? [Task] {
                let task = tableView.dequeueReusableCell(withIdentifier: "detailTaskCell", for: indexPath)
                task.textLabel?.text = tasks[indexPath.row-1].title
                return task
            }
        }
        
        return UITableViewCell()
     }
    
    
    func configure() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    

}
