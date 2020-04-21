//
//  GoalTableViewCell.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 20/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import Charts

class GoalCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: CellDelegate?
    var dataManager = DataManager()
    var statsManager = StatsManager()
    var timeManager = TimeManager()
    var completedGoalsEntry = PieChartDataEntry()
    var uncompletedGoalsEntry = PieChartDataEntry()
    var allEntries = [PieChartDataEntry]()
    var indexPath: IndexPath!
    var oldCaption: String?
    var goal: Goal!
    
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var goalCheckButton: SpringButton!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var percentLabel: SpringLabel!
    
    
    func configure() {
        goalTextField.delegate = self
        setupChart()
    }
    
    func setChartData(animated: Bool) {
        self.updateChartStats(statsManager.createStats(from: [goal], tasksOnly: true))
        
        if animated {
            pieChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
            pieChart.spin(duration: 1.0, fromAngle: 0.0, toAngle: 360.0, easingOption: .easeInOutQuad)
        }
    }
    
    func setupChart() {
        pieChart.legend.enabled = false
        pieChart.holeColor = #colorLiteral(red: 0.9449999928, green: 0.9449999928, blue: 0.9449999928, alpha: 1)
        pieChart.holeRadiusPercent = 0.87
        pieChart.transparentCircleRadiusPercent = 0.0
        allEntries = [completedGoalsEntry, uncompletedGoalsEntry]
        updateChartData()
    }
    
    func updateChartStats(_ stats: Stats?) {
        guard let stats = stats else {
            pieChart.isHidden = true
            return
        }
        pieChart.isHidden = false
        completedGoalsEntry.value = Double(stats.completed)
        uncompletedGoalsEntry.value = Double(stats.uncompleted)
        
        percentLabel.text = "\(stats.percent)%"
        percentLabel.duration = 2.0
        percentLabel.animation = "fadeIn"
        percentLabel.animate()
        
        updateChartData()
    }
    
    func updateChartData() {
        let chartDataSet = PieChartDataSet(entries: allEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let colors = [#colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1), #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)]
        
        chartDataSet.drawValuesEnabled = false
        chartDataSet.selectionShift = 0.0
        chartDataSet.colors = colors
        
        pieChart.data = chartData
    }
    
    func setGoalCheckMark() {
        if goal.completed {
            goalCheckButton.setImage(#imageLiteral(resourceName: "checkmark.pdf"), for: .normal)
            goalCheckButton.tintColor = #colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1)
            goalTextField.textColor = #colorLiteral(red: 0.1959999949, green: 0.8429999948, blue: 0.2939999998, alpha: 1)
        } else {
            goalCheckButton.setImage(#imageLiteral(resourceName: "circle.pdf"), for: .normal)
            goalCheckButton.tintColor = #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)
            goalTextField.textColor = #colorLiteral(red: 1, green: 0.2160000056, blue: 0.3729999959, alpha: 1)
        }
    }
    
    func updateTaskGoalMark() {
        var tasks = goal.tasks!.allObjects as! [Task]
        tasks.removeLast()
        
        if goal.completed == false {
            for task in tasks { dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, completed: true) }
            dataManager.updateOrDeleteGoal(goalID: goal.id, completed: true)
            delegate?.sectionChanged(at: indexPath, with: .middle)
        } else if goal.completed == true {
            for task in tasks { dataManager.updateOrDeleteTask(taskID: task.id, goalID: goal.id, completed: false) }
            dataManager.updateOrDeleteGoal(goalID: goal.id, completed: false)
            delegate?.sectionChanged(at: indexPath, with: .middle)
        }
    }
    
    func processInput(from textField: UITextField?) {
        if let textField = textField {
            let newCaption = textField.text
            if newCaption != oldCaption {
                dataManager.updateOrDeleteGoal(goalID: goal.id, newTitle: newCaption)
                delegate?.cellChanged(at: indexPath, with: .left)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
        
    @IBAction func goalEditBegun(_ sender: Any) {
        let textField = sender as? UITextField
        if let textField = textField {
            oldCaption = textField.text
        }
    }
    
    @IBAction func goalEditEnded(_ sender: Any) {
        let textField = sender as? UITextField
        processInput(from: textField)
    }
    
    @IBAction func goalCheckButtonTapped(_ sender: Any) {
        updateTaskGoalMark()
    }
}
