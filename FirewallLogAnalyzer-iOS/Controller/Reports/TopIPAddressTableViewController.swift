//
//  TopIPAddressTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 10/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class TopIPAddressTableViewController: UITableViewController {

    @IBOutlet weak var minDateButton: UIButton!
    @IBOutlet weak var maxDateButton: UIButton!
    var minDate = Date()
    var maxDate = Date()
    var toolBar = UIToolbar()
    var datePicker  = UIDatePicker()
    var isMinDate = false
    var isMaxDate = false
    var formatter = DateFormatter()
    var sourceLogs: [Log] = []
    private var logs: [Log] = []
    private var ipAddress: [String] = []
    private var ipAddressCount: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        
        minDate = formatter.date(from: "01.01.2000") ?? Date()
        maxDate = formatter.date(from: formatter.string(from: Date())) ?? Date()
        minDateButton.setTitle(self.formatter.string(from: minDate), for: .normal)
        maxDateButton.setTitle(self.formatter.string(from: maxDate), for: .normal)
        
        update()
    }
    
    @IBAction func setDateButton(_ sender: UIButton) {
        toolBar.removeFromSuperview()
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= ipAddress.count {
            return 44
        } else {
            return 0
        }
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
        logs = sourceLogs.filter({ (log) -> Bool in
            log.formatterDate <= maxDate && log.formatterDate >= minDate
        })
        setup()
    }
    
    @objc func onDoneButtonClick() {
        update()
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    func setup() {
        var values: [String : Int] = [:]
        if logs.first?.firewallType == FirewallType.kaspersky {
            let logs = self.logs as! [KasperskyLog]
            logs.forEach {
                if $0.ipAddress != "" {
                    values[$0.ipAddress] = (values[$0.ipAddress] ?? 0) + 1
                }
            }
            title = "Top 10 IP Address (Kaspersky)"
        }
        if logs.first?.firewallType == FirewallType.tplink {
            let logs = self.logs as! [TPLinkLog]
            logs.forEach {
                if $0.ipAddress != "" {
                    values[$0.ipAddress] = (values[$0.ipAddress] ?? 0) + 1
                }
            }
            title = "Top 10 IP Address (TPLink)"
        }
        if logs.first?.firewallType == FirewallType.dlink {
            let logs = self.logs as! [DLinkLog]
            logs.forEach {
                if $0.srcIP != "" {
                    values[$0.srcIP] = (values[$0.srcIP] ?? 0) + 1
                }
            }
            title = "Top 10 IP Address (DLink)"
        }
        let sortedValues = values.sorted { $0.value > $1.value }
        
        ipAddress = []
        ipAddressCount = []
        for (i, value) in sortedValues.enumerated() {
            if i == 10 { break }
            ipAddress.append(value.key)
            ipAddressCount.append(value.value)
            tableView.cellForRow(at: IndexPath(row: i + 1, column: 0))?.textLabel?.text = "IP: \(value.key) (\(value.value))"
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0  { return }
        let ip = ipAddress[indexPath.row - 1]
        let alert = UIAlertController(title: "Show IP Geolocation?", message: ip, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Show", style: .default, handler: { _ in
            self.tabBarController?.selectedIndex = 3
            let ipGeolocationController = (self.tabBarController?.viewControllers?[3] as? UINavigationController)?.topViewController as? IPGeolocationTableViewController
            ipGeolocationController?.search(ip: ip)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
