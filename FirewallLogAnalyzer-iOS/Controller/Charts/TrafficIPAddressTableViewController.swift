//
//  TrafficIPAddressTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 08/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import Charts

class TrafficIPAddressTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var ipAddressTextField: UITextField!
    @IBOutlet weak var logsCountLabel: UILabel!
    
    var formatter = DateFormatter()
    var calendar = Calendar(identifier: .gregorian)
    var sourceKasperskyLogs: [KasperskyLog] = []
    var sourceTPLinkLogs: [TPLinkLog] = []
    var sourceDLinkLogs: [DLinkLog] = []
    var kasperskyLogs: [KasperskyLog] = []
    var tplinkLogs: [TPLinkLog] = []
    var dlinkLogs: [DLinkLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        
        ipAddressTextField.delegate = self
        ipAddressTextField.returnKeyType = .done
        
        var kasperskyLoaded = false
        var tplinkLoaded = false
        var dlinkLoaded = false
        
        showActivityIndicator(in: view)
        NetworkManager.shared.updateKasperskyLogFiles { (status, logs) in
            self.sourceKasperskyLogs = logs
            self.kasperskyLogs = logs
            kasperskyLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.update()
            }
        }
        
        NetworkManager.shared.updateTPLinkLogFiles { (status, logs) in
            self.sourceTPLinkLogs = logs
            self.tplinkLogs = logs
            tplinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.update()
            }
        }
        
        NetworkManager.shared.updateDLinkLogFiles { (status, logs) in
            self.sourceDLinkLogs = logs
            self.dlinkLogs = logs
            dlinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.update()
            }
        }
    }
    
    @IBAction func changeFirewallType(_ sender: UISegmentedControl) {
        setupChart()
    }
    
    func update() {
        guard let ip = ipAddressTextField.text else { return }
        if !ip.isIPAddress() {
            kasperskyLogs = []
            tplinkLogs = []
            dlinkLogs = []
            return
        }
        kasperskyLogs = sourceKasperskyLogs.filter({ (log) -> Bool in
            log.ipAddress == ip
        })
        tplinkLogs = sourceTPLinkLogs.filter({ (log) -> Bool in
            log.ipAddress == ip
        })
        dlinkLogs = sourceDLinkLogs.filter({ (log) -> Bool in
            log.srcIP == ip
        })
        setupChart()
    }
    
    func setChartDataEntry(logs: [Log]) {
        var logsCountByDate: [Date : Int] = [:]
        
        for log in logs {
            let date = formatter.date(from: formatter.string(from: log.formatterDate))!
            logsCountByDate[date] = (logsCountByDate[date] ?? 0) + 1
        }
        
        let sortedLogsCountByDate = logsCountByDate.sorted(by: { (value1, value2) -> Bool in
            value1.key < value2.key
        })
        
        var days: [String] = []
        var values: [Double] = []
        sortedLogsCountByDate.forEach { (value) in
            days.append(formatter.string(from: value.key))
            values.append(Double(value.value))
        }
        chartView.setBarChartData(xValues: days, yValues: values, label: "Traffic count")
        logsCountLabel.text = "Logs count: \(logs.count)"
    }
    
    func setupChart() {
        
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.scaleYEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        
        chartView.rightAxis.enabled = false
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
        
        chartView.animate(yAxisDuration: 1.5)
        
        if segmentControl.selectedSegmentIndex == 0 {
            setChartDataEntry(logs: kasperskyLogs)
        } else if segmentControl.selectedSegmentIndex == 1 {
            setChartDataEntry(logs: tplinkLogs)
        } else if segmentControl.selectedSegmentIndex == 2 {
            setChartDataEntry(logs: dlinkLogs)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if ipAddressTextField.text?.isIPAddress() ?? false {
            ipAddressTextField.resignFirstResponder()
            update()
            return true
        } else {
            return false
        }
    }
}

