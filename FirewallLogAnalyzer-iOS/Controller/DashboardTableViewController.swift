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
    @IBOutlet weak var ipServerButton: UIButton!
    @IBOutlet weak var ipKasperskyButton: UIButton!
    @IBOutlet weak var ipTPLinkButton: UIButton!
    @IBOutlet weak var ipDLinkButton: UIButton!
    
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
        ipServerButton.setTitle(UserSettings.server, for: .normal)
        var kasperskyLoaded = false
        var tplinkLoaded = false
        var dlinkLoaded = false
        
        showActivityIndicator(in: view)
        NetworkManager.shared.updateKasperskyLogFiles { (status, logs) in
            self.kasperskyLogs = logs
            self.kasperskyCell.detailTextLabel?.text = "Logs count: \(logs.count)"
            self.findMoreActiveIPAddressForLastDay(logs: logs)
            kasperskyLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.lineChartSetup()
            }
        }
        
        NetworkManager.shared.updateTPLinkLogFiles { (status, logs) in
            self.tplinkLogs = logs
            self.tplinkCell.detailTextLabel?.text = "Logs count: \(logs.count)"
            self.ipTPLinkButton.setTitle("None", for: .normal)
            tplinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.lineChartSetup()
            }
        }
        
        NetworkManager.shared.updateDLinkLogFiles { (status, logs) in
            self.dlinkLogs = logs
            self.dlinkCell.detailTextLabel?.text = "Logs count: \(logs.count)"
            self.findMoreActiveIPAddressForLastDay(logs: logs)
            dlinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.lineChartSetup()
            }
        }
    }
    
    func findMoreActiveIPAddressForLastDay(logs: [KasperskyLog]) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        guard let date = formatter.date(from: formatter.string(from: Date())) else { return }
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: date) else { return }
        var ipLogs: [String : Int] = [:]
        for log in logs {
            if let logDate = formatter.date(from: log.date), logDate >= previousDate, log.ipAddress != "" {
                ipLogs[log.ipAddress] = ipLogs[log.ipAddress] ?? 0
                ipLogs[log.ipAddress] = ipLogs[log.ipAddress]! + 1
                
            }
        }
        let max = ipLogs.max { (ipLog1, ipLog2) -> Bool in
            ipLog1.value < ipLog2.value
        }
        if max?.key == nil {
            ipKasperskyButton.setTitle("None", for: .normal)
        } else {
            ipKasperskyButton.setTitle(max?.key, for: .normal)
        }
    }
    
    func findMoreActiveIPAddressForLastDay(logs: [DLinkLog]) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        guard let date = formatter.date(from: formatter.string(from: Date())) else { return }
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: date) else { return }
        var ipLogs: [String : Int] = [:]
        for log in logs {
            if let logDate = formatter.date(from: log.date), logDate >= previousDate, log.srcIP != "" {
                ipLogs[log.srcIP] = ipLogs[log.srcIP] ?? 0
                ipLogs[log.srcIP] = ipLogs[log.srcIP]! + 1
            }
        }
        let max = ipLogs.max { (ipLog1, ipLog2) -> Bool in
            ipLog1.value < ipLog2.value
        }
        
        if max?.key == nil {
            ipDLinkButton.setTitle("None", for: .normal)
        } else {
            ipDLinkButton.setTitle(max?.key, for: .normal)
        }
    }
    
    func getChartDataEntry(logs: [Log]) -> [ChartDataEntry] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var chartDataEntry: [ChartDataEntry] = []
        let date = Date()
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: date) else { return chartDataEntry }
        var logsCountForHour: [Int : Int] = [:]
        for i in 0..<24 {
            logsCountForHour[i] = 0
        }
        
        for log in logs {
            if let formatterDate = log.formatterDate {
                if formatterDate <= date && formatterDate >= previousDate {
                    let components = calendar.dateComponents([.day, .hour], from: formatterDate)
                    logsCountForHour[components.hour!] = logsCountForHour[components.hour!]! + 1
                }
            }
        }
        
        let sortedLogsCountForHour = logsCountForHour.sorted(by: { (value1, value2) -> Bool in
            value1.key < value2.key
        })
        sortedLogsCountForHour.forEach { (value) in
            chartDataEntry.append(ChartDataEntry(x: Double(value.key), y: Double(value.value)))
        }
        return chartDataEntry
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
        leftAxis.axisMaximum = 20
        leftAxis.axisMinimum = 0
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        
        chartView.rightAxis.enabled = false
        
        chartView.animate(xAxisDuration: 1.5)
        
        chartDataEntry = getChartDataEntry(logs: kasperskyLogs)
        leftAxis.axisMaximum = Double.maximum(leftAxis.axisMaximum, chartDataEntry.max(by: { (value1, value2) -> Bool in
            value1.y < value2.y
        })!.y + 30)
        
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
        
        
        chartDataEntry = getChartDataEntry(logs: tplinkLogs)
        leftAxis.axisMaximum = Double.maximum(leftAxis.axisMaximum, chartDataEntry.max(by: { (value1, value2) -> Bool in
            value1.y < value2.y
        })!.y + 30)
        
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
        
        
        chartDataEntry = getChartDataEntry(logs: dlinkLogs)
        leftAxis.axisMaximum = Double.maximum(leftAxis.axisMaximum, chartDataEntry.max(by: { (value1, value2) -> Bool in
            value1.y < value2.y
        })!.y + 30)
        
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
    
    @IBAction func showIPGeolocation(_ sender: UIButton) {
        guard let ip = sender.title(for: .normal), ip != "None" else { return }
        tabBarController?.selectedIndex = 3
        let ipGeolocationController = (tabBarController?.viewControllers?[3] as? UINavigationController)?.topViewController as? IPGeolocationTableViewController
        ipGeolocationController?.search(ip: ip)
    }
}
