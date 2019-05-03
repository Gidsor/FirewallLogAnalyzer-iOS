//
//  KasperskyLogsTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 03/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import SpreadsheetView

class KasperskyLogsTableViewController: UIViewController {
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    
    // TODO: set max width for each column after get cell if width more old
    
    var logs: [KasperskyLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        
        spreadsheetView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        spreadsheetView.intercellSpacing = CGSize(width: 4, height: 1)
        
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        
        showActivityIndicator(in: view)
        NetworkManager.shared.updateKasperskyLogFiles { (status, json) in
            guard let json = json else { return }
            self.logs = KasperskyLog.getLogs(json: json)
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

extension KasperskyLogsTableViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 11
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
                cell.label.text = "Description"
            }
            if indexPath.column == 4 {
                cell.label.text = "Type of protect"
            }
            if indexPath.column == 5 {
                cell.label.text = "Application"
            }
            if indexPath.column == 6 {
                cell.label.text = "Result"
            }
            if indexPath.column == 7 {
                cell.label.text = "Object of attack"
            }
            if indexPath.column == 8 {
                cell.label.text = "Port"
            }
            if indexPath.column == 9 {
                cell.label.text = "Protocol"
            }
            if indexPath.column == 10 {
                cell.label.text = "IP Address"
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
            cell.label.text = log.description
        }
        if indexPath.column == 4 {
            cell.label.text = log.protectType
        }
        if indexPath.column == 5 {
            cell.label.text = log.application
        }
        if indexPath.column == 6 {
            cell.label.text = log.result
        }
        if indexPath.column == 7 {
            cell.label.text = log.objectAttack
        }
        if indexPath.column == 8 {
            cell.label.text = log.port
        }
        if indexPath.column == 9 {
            cell.label.text = log.protocolNetwork
        }
        if indexPath.column == 10 {
            cell.label.text = log.ipAddress
        }
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 40
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 3 {
            return 200
        }
        if column == 4 {
            return 200
        }
        if column == 5 {
            return 200
        }
        if column == 6 {
            return 300
        }
        if column == 7 {
            return 300
        }
        if column == 10 {
            return 100
        }
        
        return 80
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: (row: \(indexPath.row), column: \(indexPath.column))")
    }
    
}
