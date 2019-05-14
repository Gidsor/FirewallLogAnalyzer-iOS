//
//  LiveTraffic24HoursTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 07/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import Charts

class LiveTraffic24HoursTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var logsCountLabel: UILabel!
    @IBOutlet weak var ipButton: UIButton!
    var minDate = Date()
    var maxDate = Date()
    var toolBar = UIToolbar()
    var datePicker  = UIDatePicker()
    var ipPicker = UIPickerView()
    var formatter = DateFormatter()
    var calendar = Calendar(identifier: .gregorian)
    var sourceKasperskyLogs: [KasperskyLog] = []
    var sourceTPLinkLogs: [TPLinkLog] = []
    var sourceDLinkLogs: [DLinkLog] = []
    var kasperskyLogs: [KasperskyLog] = []
    var tplinkLogs: [TPLinkLog] = []
    var dlinkLogs: [DLinkLog] = []
    var ipKaspersky: [String] = []
    var ipDLink: [String] = []
    var ipTPLink: [String] = []
    
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
            if status == .unknown {
                self.showAlert(type: .noInternetConnection)
                return
            }
            self.sourceKasperskyLogs = logs
            self.kasperskyLogs = logs
            self.ipKaspersky = logs.map { $0.ipAddress }
            self.ipKaspersky = self.ipKaspersky.filter { $0 != "" }
            self.ipKaspersky = Array(Set(self.ipKaspersky))
            kasperskyLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.setupChart()
            }
        }
        
        NetworkManager.shared.updateTPLinkLogFiles { (status, logs) in
            if status == .unknown {
                self.showAlert(type: .noInternetConnection)
                return
            }
            self.sourceTPLinkLogs = logs
            self.tplinkLogs = logs
            self.ipTPLink = logs.map { $0.ipAddress }
            self.ipTPLink = self.ipTPLink.filter { $0 != "" }
            self.ipTPLink = Array(Set(self.ipTPLink))
            tplinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.setupChart()
            }
        }
        
        NetworkManager.shared.updateDLinkLogFiles { (status, logs) in
            if status == .unknown {
                self.showAlert(type: .noInternetConnection)
                return
            }
            self.sourceDLinkLogs = logs
            self.dlinkLogs = logs
            self.ipDLink = logs.map { $0.srcIP }
            self.ipDLink = self.ipDLink.filter { $0 != "" }
            self.ipDLink = Array(Set(self.ipDLink))
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
    
    @IBAction func setIPButton(_ sender: UIButton) {
        toolBar.removeFromSuperview()
        ipPicker.removeFromSuperview()
        datePicker.removeFromSuperview()
        ipPicker = UIPickerView()
        ipPicker.backgroundColor = .white
        ipPicker.autoresizingMask = .flexibleWidth
        ipPicker.delegate = self
        ipPicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        view.addSubview(ipPicker)
        toolBar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneButtonClick))]
        toolBar.sizeToFit()
        view.addSubview(toolBar)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            return ipDLink.count + 1
        } else if segmentControl.selectedSegmentIndex == 1 {
            return ipTPLink.count + 1
        } else if segmentControl.selectedSegmentIndex == 2 {
            return ipKaspersky.count + 1
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            ipButton.setTitle("None", for: .normal)
        } else if segmentControl.selectedSegmentIndex == 0 {
            ipButton.setTitle(ipDLink[row - 1], for: .normal)
        } else if segmentControl.selectedSegmentIndex == 1 {
            ipButton.setTitle(ipTPLink[row - 1], for: .normal)
        } else if segmentControl.selectedSegmentIndex == 2 {
            ipButton.setTitle(ipKaspersky[row - 1], for: .normal)
        } else {
            ipButton.setTitle("None", for: .normal)
        }
        update()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "None"
        }
        if segmentControl.selectedSegmentIndex == 0 {
            return ipDLink[row - 1]
        } else if segmentControl.selectedSegmentIndex == 1 {
            return ipTPLink[row - 1]
        } else if segmentControl.selectedSegmentIndex == 2 {
            return ipKaspersky[row - 1]
        } else {
            return "None"
        }
    }
    
    @IBAction func setDateButton(_ sender: UIButton) {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
        ipPicker.removeFromSuperview()
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
        
        let ip = ipButton.title(for: .normal) ?? "None"
        kasperskyLogs = sourceKasperskyLogs.filter({ (log) -> Bool in
            if ip == "None" {
                return log.formatterDate <= maxDate && log.formatterDate >= minDate
            } else {
                return log.formatterDate <= maxDate && log.formatterDate >= minDate && log.ipAddress == ip
            }
        })
        tplinkLogs = sourceTPLinkLogs.filter({ (log) -> Bool in
            if ip == "None" {
                return log.formatterDate <= maxDate && log.formatterDate >= minDate
            } else {
                return log.formatterDate <= maxDate && log.formatterDate >= minDate && log.ipAddress == ip
            }
        })
        dlinkLogs = sourceDLinkLogs.filter({ (log) -> Bool in
            if ip == "None" {
                return log.formatterDate <= maxDate && log.formatterDate >= minDate
            } else {
                return log.formatterDate <= maxDate && log.formatterDate >= minDate && log.srcIP == ip
            }
        })
        setupChart()
    }
    
    @objc func onDoneButtonClick() {
        update()
        ipPicker.removeFromSuperview()
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
