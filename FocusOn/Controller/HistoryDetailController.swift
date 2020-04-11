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
        if let tasks = goal.tasks?.allObjects as? [Task] {
            let task = tableView.dequeueReusableCell(withIdentifier: "historyGoalCell", for: indexPath)
            task.textLabel?.text = tasks[indexPath.row].title
            print("called")
            return task
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
        
        
        print(goal)
    }
    

}
