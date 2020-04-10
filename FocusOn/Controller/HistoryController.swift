//
//  HistoryController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 18/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import CoreData

class HistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var dataManager = DataManager()
    var historyManager = HistoryManager()
    var completeHistory: [Goal]?
    var history = [History]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        history = historyManager.sortHistoryData(goals: dataManager.fetchAllGoals()!)
        //print(history)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return history.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if history[section].type == .month {
            return 1
        }
        
        if history[section].type == .day {
            return history[section].descriptions?.count ?? 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if history[indexPath.section].type == .month {
            let summary = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
            summary.textLabel?.text = history[indexPath.section].headline
            return summary
        }
        
        if history[indexPath.section].type == .day {
            let goal = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
            goal.textLabel?.text = history[indexPath.section].descriptions![indexPath.row].title
            return goal
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let text = history[section].date
        return text
    }
    
}
