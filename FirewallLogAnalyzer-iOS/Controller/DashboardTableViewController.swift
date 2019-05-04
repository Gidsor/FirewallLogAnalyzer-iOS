//
//  DashboardTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 03/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import Charts

class DashboardTableViewController: UITableViewController {
    @IBOutlet weak var kasperskyCell: UITableViewCell!
    @IBOutlet weak var tplinkCell: UITableViewCell!
    @IBOutlet weak var dlinkCell: UITableViewCell!
    @IBOutlet weak var chartView: LineChartView!
    
    var kasperskyLogs: [KasperskyLog] = []
    var tplinkLogs: [TPLinkLog] = []
    var dlinkLogs: [DLinkLog] = []
    
    var chartDataEntry: [ChartDataEntry] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()

        updateDashboard()
    }
    
    func updateDashboard() {
        NetworkManager.shared.updateKasperskyLogFiles { (status, logs) in
            self.kasperskyLogs = logs
            self.kasperskyCell.detailTextLabel?.text = "Logs count: \(logs.count)"
        }
        
        NetworkManager.shared.updateTPLinkLogFiles { (status, logs) in
            self.tplinkLogs = logs
            self.tplinkCell.detailTextLabel?.text = "Logs count: \(logs.count)"
        }
        
        NetworkManager.shared.updateDLinkLogFiles { (status, logs) in
            self.dlinkLogs = logs
            self.dlinkCell.detailTextLabel?.text = "Logs count: \(logs.count)"
        }
        
        lineChartSetup()
    }
    
    func lineChartSetup() {
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        
        let l = chartView.legend
        l.form = .line
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.textColor = .black
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        
        let xAxis = chartView.xAxis
        xAxis.labelCount = 23
        xAxis.spaceMin = 0
        xAxis.spaceMax = 0
        xAxis.labelFont = .systemFont(ofSize: 8)
        xAxis.labelTextColor = .black
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = false
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = .black
        leftAxis.axisMaximum = 200
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        
        chartView.rightAxis.enabled = false
        
        chartView.animate(xAxisDuration: 1.5)
        
        chartDataEntry = []
        for i in 0..<24 {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double.random(in: 0..<150))
            chartDataEntry.append(dataEntry)
        }
        
        let set1 = LineChartDataSet(values: chartDataEntry, label: "Kaspersky")
        set1.axisDependency = .left
        set1.setColor(.red)
        set1.setCircleColor(.red)
        set1.lineWidth = 2
        set1.circleRadius = 3
        set1.fillAlpha = 65/255
        set1.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
        
        
        chartDataEntry = []
        for i in 0..<24 {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double.random(in: 0..<150))
            chartDataEntry.append(dataEntry)
        }
        
        let set2 = LineChartDataSet(values: chartDataEntry, label: "TPLink")
        set2.axisDependency = .left
        set2.setColor(.green)
        set2.setCircleColor(.green)
        set2.lineWidth = 2
        set2.circleRadius = 3
        set2.fillAlpha = 65/255
        set2.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        set2.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set2.drawCircleHoleEnabled = false
        
        
        chartDataEntry = []
        for i in 0..<24 {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double.random(in: 0..<150))
            chartDataEntry.append(dataEntry)
        }
        
        let set3 = LineChartDataSet(values: chartDataEntry, label: "DLink")
        set3.axisDependency = .left
        set3.setColor(.blue)
        set3.setCircleColor(.blue)
        set3.lineWidth = 2
        set3.circleRadius = 3
        set3.fillAlpha = 65/255
        set3.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        set3.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set3.drawCircleHoleEnabled = false
        let lineChartData = LineChartData(dataSets: [set1, set2, set3])
        
        chartView.data = lineChartData
    }
}
