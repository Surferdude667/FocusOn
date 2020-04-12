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
    
    
    
    // MARK:- TableView delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return history[section].date
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch history[section].type {
        case .month:
            return 1
        case .day:
            return history[section].goals?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch history[indexPath.section].type {
        case .month:
            let summary = tableView.dequeueReusableCell(withIdentifier: "historySummaryCell", for: indexPath)
            summary.textLabel?.text = history[indexPath.section].summary
            return summary
        case .day:
            let goal = tableView.dequeueReusableCell(withIdentifier: "historyGoalCell", for: indexPath) as! HistoryGoalCell
            goal.textLabel?.text = history[indexPath.section].goals![indexPath.row].title
            goal.goal = history[indexPath.section].goals![indexPath.row]
            return goal
        }
    }
        
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        switch history[section].type {
        case .month:
            view.tintColor = UIColor.black
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.white
        case .day:
            view.tintColor = UIColor.gray
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.black
        }
    }
    
    
    // MARK:- ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        history = historyManager.sortHistoryData(goals: dataManager.fetchAllGoals()!)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "historyDetailSeque" {
            
            let historyDetailController = segue.destination as! HistoryDetailController
            let indexPath = self.tableView.indexPathForSelectedRow
            let cell = self.tableView.cellForRow(at: indexPath!) as! HistoryGoalCell
            historyDetailController.goal = cell.goal
        }
    }
    
}
