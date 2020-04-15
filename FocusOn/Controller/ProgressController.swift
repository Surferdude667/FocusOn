//
//  ProgressController.swift
//  FocusOn
//
//  Created by Bjørn Lau Jørgensen on 18/03/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import Charts

class ProgressController: UIViewController {
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
    var completedGoalsEntry = PieChartDataEntry()
    var uncompletedGoalsEntry = PieChartDataEntry()
    var allEntries = [PieChartDataEntry]()
    var statsManager = StatsManager()
    var dataManager = DataManager()
    var timeManager = TimeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        segmentControlUpdate()
    }
    
    func segmentControlUpdate() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            // TODAY
            let todayGoals = dataManager.fetchGoals(from: Date())
            updateChartStats(statsManager.createStats(from: todayGoals))
        case 1:
            // WEEK
            let firstDayInWeek = timeManager.startOfWeek(for: Date())
            let weekGoals = dataManager.fetchHistory(from: firstDayInWeek, to: Date())
            updateChartStats(statsManager.createStats(from: weekGoals))
        case 2:
            // MONTH
            let firstDayInMonth = timeManager.startOfMonth(for: Date())
            let monthGoals = dataManager.fetchHistory(from: firstDayInMonth, to: Date())
            updateChartStats(statsManager.createStats(from: monthGoals))
        case 3:
            // ALL TIME
            let allGoals = dataManager.fetchHistory(from: nil, to: nil)
            updateChartStats(statsManager.createStats(from: allGoals))
        default:
            break
        }
    }
    
    func setupChart() {
        pieChart.legend.enabled = false
        pieChart.holeColor = .black
        pieChart.holeRadiusPercent = 0.95
        pieChart.transparentCircleRadiusPercent = 0.0
        allEntries = [completedGoalsEntry, uncompletedGoalsEntry]
        updateChartData()
    }
    
    
    func updateChartData() {
        let chartDataSet = PieChartDataSet(entries: allEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let colors = [UIColor.green, UIColor.red]
        
        chartDataSet.drawValuesEnabled = false
        chartDataSet.selectionShift = 0.0
        chartDataSet.colors = colors
        
        pieChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        pieChart.spin(duration: 1.0, fromAngle: 0.0, toAngle: 360.0, easingOption: .easeInOutQuad)
        pieChart.data = chartData
    }
    
    
    func animateIncrement(to: Int, from: Int) {
        if from == to {
            if to == 0 {
                percentLabel.text = "0%"
            }
            return
        }
        percentLabel.text = "\(0 + from + 1)%"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            self.animateIncrement(to: to, from: from + 1)
        }
    }
    
    func updateChartStats(_ stats: Stats?) {
        guard let stats = stats else {
            percentLabel.text = "🥺"
            completedLabel.text = "No data yet."
            return
        }
        
        completedGoalsEntry.value = Double(stats.completed)
        uncompletedGoalsEntry.value = Double(stats.uncompleted)
        animateIncrement(to: stats.percent, from: 0)
        completedLabel.text = "completed"
        
        if stats.from == stats.to {
            dateLabel.text = stats.from
        } else {
           dateLabel.text = "\(stats.from)  -  \(stats.to)"
        }
        
        updateChartData()
    }
    
    
    @IBAction func segmentControlAction(_ sender: Any) {
        segmentControlUpdate()
    }
}
