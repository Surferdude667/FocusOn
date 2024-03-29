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
            let summary = tableView.dequeueReusableCell(withIdentifier: "historySummaryCell", for: indexPath) as! HistorySummaryCell
            summary.summaryLabel.text = history[indexPath.section].summary
            return summary
        case .day:
            let goal = tableView.dequeueReusableCell(withIdentifier: "historyGoalCell", for: indexPath) as! HistoryGoalCell
            goal.goalTitleLabel.text = history[indexPath.section].goals![indexPath.row].title
            goal.goal = history[indexPath.section].goals![indexPath.row]
            goal.setGoalCheckMark()
            return goal
        }
    }
        
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        switch history[section].type {
        case .month:
            view.tintColor = #colorLiteral(red: 0.02745098039, green: 0.03529411765, blue: 0.0431372549, alpha: 1)
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = #colorLiteral(red: 0.0390000008, green: 0.7919999957, blue: 0.7570000291, alpha: 1)
            header.textLabel?.textAlignment = .center
        case .day:
            view.tintColor = #colorLiteral(red: 0.02745098039, green: 0.03529411765, blue: 0.0431372549, alpha: 1)
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            header.textLabel?.textAlignment = .center
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func setStatusBar() {
        let statusBarFrame = UIApplication.shared.statusBarFrame
        let statusBarView = UIView(frame: statusBarFrame)
        self.view.addSubview(statusBarView)
        statusBarView.backgroundColor = #colorLiteral(red: 0.02745098039, green: 0.03529411765, blue: 0.0431372549, alpha: 1)
    }
    
        
    // MARK:- ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        tableView.delegate = self
        tableView.dataSource = self
        setStatusBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        history = historyManager.sortHistoryData(goals: dataManager.fetchAllGoals()!)
        tableView.reloadData()
        self.navigationController?.navigationBar.isHidden = true
        
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
