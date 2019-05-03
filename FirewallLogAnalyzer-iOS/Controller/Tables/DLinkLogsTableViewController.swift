//
//  DLinkLogsTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 03/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import SpreadsheetView

class DLinkLogsTableViewController: UIViewController {
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    
    // TODO: set max width for each column after get cell if width more old
    
    var logs: [DLinkLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        
        spreadsheetView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        spreadsheetView.intercellSpacing = CGSize(width: 4, height: 1)
        
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        showActivityIndicator(in: view)
        NetworkManager.shared.updateDLinkLogFiles { (status, json) in
            guard let json = json else { return }
            self.logs = DLinkLog.getLogs(json: json)
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

extension DLinkLogsTableViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 17
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
                cell.label.text = "Severity"
            }
            if indexPath.column == 4 {
                cell.label.text = "Category"
            }
            if indexPath.column == 5 {
                cell.label.text = "ID of category"
            }
            if indexPath.column == 6 {
                cell.label.text = "Rule"
            }
            if indexPath.column == 7 {
                cell.label.text = "Protocol"
            }
            if indexPath.column == 8 {
                cell.label.text = "Source If"
            }
            if indexPath.column == 9 {
                cell.label.text = "Destination If"
            }
            if indexPath.column == 10 {
                cell.label.text = "Source IP"
            }
            if indexPath.column == 11 {
                cell.label.text = "Destination IP"
            }
            if indexPath.column == 13 {
                cell.label.text = "Source Port"
            }
            if indexPath.column == 14 {
                cell.label.text = "Destination Port"
            }
            if indexPath.column == 15 {
                cell.label.text = "Event"
            }
            if indexPath.column == 16 {
                cell.label.text = "Action"
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
            cell.label.text = log.severity
        }
        if indexPath.column == 4 {
            cell.label.text = log.category
        }
        if indexPath.column == 5 {
            cell.label.text = log.categoryID
        }
        if indexPath.column == 6 {
            cell.label.text = log.rule
        }
        if indexPath.column == 7 {
            cell.label.text = log.protocolNetwork
        }
        if indexPath.column == 8 {
            cell.label.text = log.srcIf
        }
        if indexPath.column == 9 {
            cell.label.text = log.dstIf
        }
        if indexPath.column == 10 {
            cell.label.text = log.srcIP
        }
        if indexPath.column == 11 {
            cell.label.text = log.dstIP
        }
        if indexPath.column == 13 {
            cell.label.text = log.srcPort
        }
        if indexPath.column == 14 {
            cell.label.text = log.dstPort
        }
        if indexPath.column == 15 {
            cell.label.text = log.event
        }
        if indexPath.column == 16 {
            cell.label.text = log.action
        }
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 40
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 6 {
            return 120
        }
        if column == 15 {
            return 160
        }
        return 80
    }
    
}
