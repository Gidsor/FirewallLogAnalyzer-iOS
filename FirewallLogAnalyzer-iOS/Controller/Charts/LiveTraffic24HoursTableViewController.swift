//
//  LiveTraffic24HoursTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 07/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import Charts

class LiveTraffic24HoursTableViewController: UITableViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var logsCountLabel: UILabel!
    var minDate = Date()
    var maxDate = Date()
    var toolBar = UIToolbar()
    var datePicker  = UIDatePicker()
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
        
        var kasperskyLoaded = false
        var tplinkLoaded = false
        var dlinkLoaded = false
        
        minDate = formatter.date(from: formatter.string(from: Date()))!
        maxDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: minDate)!
        datePickerButton.setTitle(formatter.string(from: minDate), for: .normal)
        
        showActivityIndicator(in: view)
        NetworkManager.shared.updateKasperskyLogFiles { (status, logs) in
            self.sourceKasperskyLogs = logs
            self.kasperskyLogs = logs
            kasperskyLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.setupChart()
            }
        }
        
        NetworkManager.shared.updateTPLinkLogFiles { (status, logs) in
            self.sourceTPLinkLogs = logs
            self.tplinkLogs = logs
            tplinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.setupChart()
            }
        }
        
        NetworkManager.shared.updateDLinkLogFiles { (status, logs) in
            self.sourceDLinkLogs = logs
            self.dlinkLogs = logs
            dlinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.setupChart()
            }
        }
    }
    
    @IBAction func changeFirewallType(_ sender: UISegmentedControl) {
        setupChart()
    }
    
    @IBAction func setDateButton(_ sender: UIButton) {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
        datePicker = UIDatePicker()
        datePicker.setDate(formatter.date(from: datePickerButton.title(for: .normal)!)!, animated: true)
        
        datePicker.backgroundColor = UIColor.white
        
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .date
        
        datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(datePicker)
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneButtonClick))]
        toolBar.sizeToFit()
        view.addSubview(toolBar)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker?) {
        update()
    }
    
    func update() {
        minDate = formatter.date(from: formatter.string(from: datePicker.date))!
        maxDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: minDate)!
        datePickerButton.setTitle(formatter.string(from: datePicker.date), for: .normal)
        
        kasperskyLogs = sourceKasperskyLogs.filter({ (log) -> Bool in
            log.formatterDate <= maxDate && log.formatterDate >= minDate
        })
        tplinkLogs = sourceTPLinkLogs.filter({ (log) -> Bool in
            log.formatterDate <= maxDate && log.formatterDate >= minDate
        })
        dlinkLogs = sourceDLinkLogs.filter({ (log) -> Bool in
            log.formatterDate <= maxDate && log.formatterDate >= minDate
        })
        setupChart()
    }
    
    @objc func onDoneButtonClick() {
        update()
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    func getChartDataEntry(logs: [Log]) -> [ChartDataEntry] {
        var chartDataEntry: [ChartDataEntry] = []
        var logsCountForHour: [Int : Int] = [:]
        for i in 0..<24 {
            logsCountForHour[i] = 0
        }
        
        for log in logs {
            if log.formatterDate <= maxDate && log.formatterDate >= minDate {
                let components = calendar.dateComponents([.day, .hour], from: log.formatterDate)
                logsCountForHour[components.hour!] = logsCountForHour[components.hour!]! + 1
            }
        }
        
        let sortedLogsCountForHour = logsCountForHour.sorted(by: { (value1, value2) -> Bool in
            value1.key < value2.key
        })
        sortedLogsCountForHour.forEach { (value) in
            chartDataEntry.append(ChartDataEntry(x: Double(value.key), y: Double(value.value)))
        }
        logsCountLabel.text = "Logs count: \(logs.count)"
        return chartDataEntry
    }
    
    func setupChart() {
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
        
        if segmentControl.selectedSegmentIndex == 2 {
            let chartDataEntry = getChartDataEntry(logs: kasperskyLogs)
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
            chartView.data = LineChartData(dataSet: set1)
        } else if segmentControl.selectedSegmentIndex == 1 {
            let chartDataEntry = getChartDataEntry(logs: tplinkLogs)
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
            chartView.data = LineChartData(dataSet: set2)
        } else if segmentControl.selectedSegmentIndex == 0 {
            let chartDataEntry = getChartDataEntry(logs: dlinkLogs)
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
            chartView.data = LineChartData(dataSet: set3)
        }
    }
}
