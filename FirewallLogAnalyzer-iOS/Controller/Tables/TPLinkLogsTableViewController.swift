//
//  TPLinkLogsTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 03/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import SpreadsheetView

class TPLinkLogsTableViewController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    
    // TODO: set max width for each column after get cell if width more old
    
    var logs: [TPLinkLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        
        spreadsheetView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        spreadsheetView.intercellSpacing = CGSize(width: 4, height: 1)
        
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        
        showActivityIndicator(in: view)
        NetworkManager.shared.updateTPLinkLogFiles { (status, json) in
            guard let json = json else { return }
            self.logs = TPLinkLog.getLogs(json: json)
            self.spreadsheetView.reloadData()
            self.countLabel.text = "Logs count: \(self.logs.count)"
            self.hideActivityIndicator(in: self.view)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        spreadsheetView.flashScrollIndicators()
    }
    
}

extension TPLinkLogsTableViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 9
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return logs.count + 1
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return logs.count == 0 ? 0 : 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
        // For headers
        if indexPath.row == 0 {
            if indexPath.column == 0 {
                cell.label.text = "ID"
            }
            if indexPath.column == 1 {
                cell.label.text = "Date"
            }
            if indexPath.column == 2 {
                cell.label.text = "Time"
            }
            if indexPath.column == 3 {
                cell.label.text = "Type of event"
            }
            if indexPath.column == 4 {
                cell.label.text = "Level significance"
            }
            if indexPath.column == 5 {
                cell.label.text = "Log content"
            }
            if indexPath.column == 6 {
                cell.label.text = "MAC address"
            }
            if indexPath.column == 7 {
                cell.label.text = "IP address"
            }
            if indexPath.column == 8 {
                cell.label.text = "Protocol"
            }
            return cell
        }
        
        // For information
        let log = logs[indexPath.row - 1]
        if indexPath.column == 0 {
            cell.label.text = "\(log.id)"
        }
        if indexPath.column == 1 {
            cell.label.text = log.date
        }
        if indexPath.column == 2 {
            cell.label.text = log.time
        }
        if indexPath.column == 3 {
            cell.label.text = log.typeEvent
        }
        if indexPath.column == 4 {
            cell.label.text = log.levelSignificance
        }
        if indexPath.column == 5 {
            cell.label.text = log.logContent
        }
        if indexPath.column == 6 {
            cell.label.text = log.macAddress
        }
        if indexPath.column == 7 {
            cell.label.text = log.ipAddress
        }
        if indexPath.column == 8 {
            cell.label.text = log.protocolNetwork
        }
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 40
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 4 {
            return 100
        }
        if column == 5 {
            return 300
        }
        if column == 6 {
            return 120
        }
        
        return 80
    }
}

