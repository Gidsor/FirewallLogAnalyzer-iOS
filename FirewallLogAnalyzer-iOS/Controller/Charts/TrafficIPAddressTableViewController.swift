//
//  TrafficIPAddressTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 08/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import Charts

class TrafficIPAddressTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var ipButton: UIButton!
    @IBOutlet weak var logsCountLabel: UILabel!
    
    var toolBar = UIToolbar()
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
        
        showActivityIndicator(in: view)
        NetworkManager.shared.updateKasperskyLogFiles { (status, logs) in
            self.sourceKasperskyLogs = logs
            self.kasperskyLogs = logs
            self.ipKaspersky = logs.map { $0.ipAddress }
            self.ipKaspersky = self.ipKaspersky.filter { $0 != "" }
            self.ipKaspersky = Array(Set(self.ipKaspersky))
            kasperskyLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.update()
            }
        }
        
        NetworkManager.shared.updateTPLinkLogFiles { (status, logs) in
            self.sourceTPLinkLogs = logs
            self.tplinkLogs = logs
            self.ipTPLink = logs.map { $0.ipAddress }
            self.ipTPLink = self.ipTPLink.filter { $0 != "" }
            self.ipTPLink = Array(Set(self.ipTPLink))
            tplinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
                self.update()
            }
        }
        
        NetworkManager.shared.updateDLinkLogFiles { (status, logs) in
            self.sourceDLinkLogs = logs
            self.dlinkLogs = logs
            self.ipDLink = logs.map { $0.srcIP }
            self.ipDLink = self.ipDLink.filter { $0 != "" }
            self.ipDLink = Array(Set(self.ipDLink))
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
    
    @IBAction func setIPButton(_ sender: UIButton) {
        toolBar.removeFromSuperview()
        ipPicker.removeFromSuperview()
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
    
    func update() {
        let ip = ipButton.title(for: .normal) ?? "None"
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
    
    @objc func onDoneButtonClick() {
        update()
        toolBar.removeFromSuperview()
        ipPicker.removeFromSuperview()
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
        
        if segmentControl.selectedSegmentIndex == 2 {
            setChartDataEntry(logs: kasperskyLogs)
        } else if segmentControl.selectedSegmentIndex == 1 {
            setChartDataEntry(logs: tplinkLogs)
        } else if segmentControl.selectedSegmentIndex == 0 {
            setChartDataEntry(logs: dlinkLogs)
        }
    }
}

