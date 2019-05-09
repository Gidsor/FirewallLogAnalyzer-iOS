//
//  SeverityLevelTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 09/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import Charts

class SeverityLevelTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var minDateButton: UIButton!
    @IBOutlet weak var maxDateButton: UIButton!
    @IBOutlet weak var logsCountLabel: UILabel!
    @IBOutlet weak var ipButton: UIButton!
    var minDate = Date()
    var maxDate = Date()
    var toolBar = UIToolbar()
    var datePicker  = UIDatePicker()
    var ipPicker = UIPickerView()
    var isMinDate = false
    var isMaxDate = false
    var formatter = DateFormatter()
    var calendar = Calendar(identifier: .gregorian)
    var sourceTPLinkLogs: [TPLinkLog] = []
    var sourceDLinkLogs: [DLinkLog] = []
    var tplinkLogs: [TPLinkLog] = []
    var dlinkLogs: [DLinkLog] = []
    var ipDLink: [String] = []
    var ipTPLink: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        
        var tplinkLoaded = false
        var dlinkLoaded = false
        
        minDate = formatter.date(from: "01.01.2000") ?? Date()
        maxDate = formatter.date(from: formatter.string(from: Date())) ?? Date()
        minDateButton.setTitle(self.formatter.string(from: minDate), for: .normal)
        maxDateButton.setTitle(self.formatter.string(from: maxDate), for: .normal)
        
        showActivityIndicator(in: view)
        
        NetworkManager.shared.updateTPLinkLogFiles { (status, logs) in
            self.sourceTPLinkLogs = logs
            self.tplinkLogs = logs
            self.ipTPLink = logs.map { $0.ipAddress }
            self.ipTPLink = self.ipTPLink.filter { $0 != "" }
            self.ipTPLink = Array(Set(self.ipTPLink))
            tplinkLoaded = true
            if tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.setupChart()
            }
        }
        
        NetworkManager.shared.updateDLinkLogFiles { (status, logs) in
            self.sourceDLinkLogs = logs
            self.dlinkLogs = logs
            self.ipDLink = logs.map { $0.srcIP }
            self.ipDLink = self.ipDLink.filter { $0 != "" }
            self.ipDLink = Array(Set(self.ipDLink))
            dlinkLoaded = true
            if tplinkLoaded && dlinkLoaded {
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
        } else {
            return "None"
        }
    }
    
    @IBAction func setDateButton(_ sender: UIButton) {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
        ipPicker.removeFromSuperview()
        datePicker = UIDatePicker()
        if sender == minDateButton {
            isMinDate = true
            isMaxDate = false
            datePicker.setDate(formatter.date(from: minDateButton.title(for: .normal) ?? "01.01.2000") ?? Date(), animated: true)
        } else {
            isMinDate = false
            isMaxDate = true
            datePicker.setDate(formatter.date(from: maxDateButton.title(for: .normal) ?? "01.01.2000") ?? Date(), animated: true)
        }
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
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        if isMinDate {
            minDate = datePicker.date
            minDateButton.setTitle(formatter.string(from: datePicker.date), for: .normal)
        } else if isMaxDate {
            maxDate = datePicker.date
            maxDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: maxDate) ?? Date()
            maxDateButton.setTitle(formatter.string(from: datePicker.date), for: .normal)
        }
        let ip = ipButton.title(for: .normal) ?? "None"
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
    
    func setChartDataEntry(logs: [TPLinkLog]) {
        var logsCountByDate: [String : Int] = [:]
        
        for log in logs {
            if log.formatterDate <= maxDate && log.formatterDate >= minDate {
                logsCountByDate[log.levelSignificance] = (logsCountByDate[log.levelSignificance] ?? 0) + 1
            }
        }
        
        let sortedLogsCountByDate = logsCountByDate.sorted(by: { (value1, value2) -> Bool in
            value1.key < value2.key
        })
        
        var events: [String] = []
        var values: [Double] = []
        sortedLogsCountByDate.forEach { (value) in
            events.append(value.key)
            values.append(Double(value.value))
        }
        chartView.setBarChartData(xValues: events, yValues: values, label: " count")
        logsCountLabel.text = "Logs count: \(logs.count)"
    }
    
    func setChartDataEntry(logs: [DLinkLog]) {
        var logsCountByDate: [String : Int] = [:]
        
        for log in logs {
            if log.formatterDate <= maxDate && log.formatterDate >= minDate {
                logsCountByDate[log.severity] = (logsCountByDate[log.severity] ?? 0) + 1
            }
        }
        
        let sortedLogsCountByDate = logsCountByDate.sorted(by: { (value1, value2) -> Bool in
            value1.key < value2.key
        })
        
        var events: [String] = []
        var values: [Double] = []
        sortedLogsCountByDate.forEach { (value) in
            events.append(value.key)
            values.append(Double(value.value))
        }
        chartView.setBarChartData(xValues: events, yValues: values, label: "Events count")
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
        
        if segmentControl.selectedSegmentIndex == 1 {
            setChartDataEntry(logs: tplinkLogs)
        } else if segmentControl.selectedSegmentIndex == 0 {
            setChartDataEntry(logs: dlinkLogs)
        }
    }
}
