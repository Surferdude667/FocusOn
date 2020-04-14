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
    
    var completedGoalsEntry = PieChartDataEntry()
    var uncompletedGoalsEntry = PieChartDataEntry()
    var allEntries = [PieChartDataEntry]()
    var statsManager = StatsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
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
        if from == to { return }
        percentLabel.text = "\(0 + from + 1)%"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            self.animateIncrement(to: to, from: from + 1)
        }
    }
    
    
    @IBAction func segmentControlAction(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            completedGoalsEntry.value = 10
            uncompletedGoalsEntry.value = 0
            updateChartData()
            animateIncrement(to: 100, from: 0)
            print("Today")
        case 1:
            completedGoalsEntry.value = 30
            updateChartData()
            animateIncrement(to: 100, from: 0)
            print("This week")
        case 2:
            let monthStats = statsManager.thisMonth()
            // TODO: Move to seperate functions.
            completedGoalsEntry.value = Double(monthStats.completed)
            uncompletedGoalsEntry.value = Double(monthStats.uncompleted)
            updateChartData()
            animateIncrement(to: monthStats.percent, from: 0)
            dateLabel.text = "\(monthStats.from)  -  \(monthStats.to)"
            
            print("This month")
        case 3:
            completedGoalsEntry.value = 50
            uncompletedGoalsEntry.value = 50
            updateChartData()
            animateIncrement(to: 50, from: 0)
            print("All time")
        default:
            break
        }
    }
}
