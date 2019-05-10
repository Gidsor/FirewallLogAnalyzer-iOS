//
//  ChartTPLinkSelectTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 10/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class ChartTPLinkSelectTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var minDateButton: UIButton!
    @IBOutlet weak var maxDateButton: UIButton!
    @IBOutlet weak var ipButton: UIButton!
    
    @IBOutlet weak var mostActiveSwitch: UISwitch!
    @IBOutlet weak var liveTrafficSwitch: UISwitch!
    @IBOutlet weak var liveTraffic24HoursSwitch: UISwitch!
    @IBOutlet weak var eventsSwitch: UISwitch!
    @IBOutlet weak var severityLevelSwitch: UISwitch!
    @IBOutlet weak var protocolsSwitch: UISwitch!
    @IBOutlet weak var tableOfLogsSwitch: UISwitch!
    
    var formatter = DateFormatter()
    var calendar = Calendar(identifier: .gregorian)
    var toolBar = UIToolbar()
    var datePicker = UIDatePicker()
    var ipPicker = UIPickerView()
    var minDate = Date()
    var maxDate = Date()
    var isMinDate = false
    var isMaxDate = false
    var sourceTPLinkLogs: [TPLinkLog] = []
    var tplinkLogs: [TPLinkLog] = []
    var ipTPLink: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        
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
            self.hideActivityIndicator(in: self.view)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateReport", let destination = segue.destination as? ChartTPLinkReportTableViewController {
            var selectedCharts: [SelectCharts] = []
            if mostActiveSwitch.isOn { selectedCharts.append(.mostActive) }
            if liveTrafficSwitch.isOn { selectedCharts.append(.liveTraffic) }
            if liveTraffic24HoursSwitch.isOn { selectedCharts.append(.liveTraffic24Hours) }
            if eventsSwitch.isOn { selectedCharts.append(.events) }
            if severityLevelSwitch.isOn { selectedCharts.append(.severityLevel) }
            if protocolsSwitch.isOn { selectedCharts.append(.protocols) }
            if tableOfLogsSwitch.isOn { selectedCharts.append(.tableOfLogs) }
            destination.selectedCharts = selectedCharts
            destination.ip = ipButton.title(for: .normal) ?? "None"
            destination.minDate = minDate
            destination.maxDate = maxDate
            destination.logs = tplinkLogs
        }
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
        return ipTPLink.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            ipButton.setTitle("None", for: .normal)
        } else {
            ipButton.setTitle(ipTPLink[row - 1], for: .normal)
        }
        update()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "None"
        }
        return ipTPLink[row - 1]
    }
    
    
    @IBAction func setDateButton(_ sender: UIButton) {
        toolBar.removeFromSuperview()
        ipPicker.removeFromSuperview()
        datePicker.removeFromSuperview()
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
        datePicker.backgroundColor = .white
        
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .date
        
        datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        view.addSubview(datePicker)
        
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
    }
    
    @objc func onDoneButtonClick() {
        update()
        ipPicker.removeFromSuperview()
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
}
