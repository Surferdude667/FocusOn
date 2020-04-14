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
    
    var completedGoalsEntry = PieChartDataEntry(value: 10)
    var unfinishedGoalsEntry = PieChartDataEntry(value: 5)
    
    var numberOfEntries = [PieChartDataEntry]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieChart.chartDescription?.text = "Description"
        
        completedGoalsEntry.label = "Completed"
        unfinishedGoalsEntry.label = "Unfinished"
        
        numberOfEntries = [completedGoalsEntry, unfinishedGoalsEntry]
        
        updateChartData()
    }
    
    
    func updateChartData() {
        let chartDataSet = PieChartDataSet(entries: numberOfEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [UIColor.green, UIColor.red]
        chartDataSet.colors = colors
        
        pieChart.data = chartData
    }
    
}
