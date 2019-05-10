//
//  SearchKasperskyReportTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 10/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import SpreadsheetView

class SearchKasperskyReportTableViewController: UITableViewController {

    enum Sorting {
        case ascending
        case descending
        
        var symbol: String {
            switch self {
            case .ascending:
                return "↑"
            case .descending:
                return "↓"
            }
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    var sortedColumn = 0
    var sortedDirection: Sorting = .ascending
    var ip = "None"
    var minDate = Date()
    var maxDate = Date()
    var formatter = DateFormatter()
    var calendar = Calendar(identifier: .gregorian)
    var selectedCharts: [SelectCharts] = []
    var logs: [KasperskyLog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        spreadsheetView.intercellSpacing = CGSize(width: 4, height: 1)
        spreadsheetView.bounces = false
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        
        dateLabel.text = "Date: \(formatter.string(from: minDate)) – \(formatter.string(from: maxDate))"
        ipLabel.text = "IP: \(ip)"
        countLabel.text = "Logs count: \(logs.count)"
        
        spreadsheetView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        spreadsheetView.flashScrollIndicators()
    }
}

extension SearchKasperskyReportTableViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
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
            
            if indexPath.column == sortedColumn {
                cell.label.text = (cell.label.text ?? "") + sortedDirection.symbol
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
        if indexPath.row == 0 {
            if sortedColumn == indexPath.column {
                if sortedDirection == .ascending {
                    sortedDirection = .descending
                } else {
                    sortedDirection = .ascending
                }
            } else {
                sortedColumn = indexPath.column
                sortedDirection = .ascending
            }
            
            if indexPath.column == 0 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.id < $1.id })
                } else {
                    logs = logs.sorted(by: { $0.id > $1.id })
                }
            }
            if indexPath.column == 1 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.date < $1.date })
                } else {
                    logs = logs.sorted(by: { $0.date > $1.date })
                }
            }
            if indexPath.column == 2 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.time < $1.time })
                } else {
                    logs = logs.sorted(by: { $0.time > $1.time })
                }
            }
            if indexPath.column == 3 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.description < $1.description })
                } else {
                    logs = logs.sorted(by: { $0.description > $1.description })
                }
            }
            if indexPath.column == 4 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.protectType < $1.protectType })
                } else {
                    logs = logs.sorted(by: { $0.protectType > $1.protectType })
                }
            }
            if indexPath.column == 5 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.application < $1.application })
                } else {
                    logs = logs.sorted(by: { $0.application > $1.application })
                }
            }
            if indexPath.column == 6 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.result < $1.result })
                } else {
                    logs = logs.sorted(by: { $0.result > $1.result })
                }
            }
            if indexPath.column == 7 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.objectAttack < $1.objectAttack })
                } else {
                    logs = logs.sorted(by: { $0.objectAttack > $1.objectAttack })
                }
            }
            if indexPath.column == 8 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.port < $1.port })
                } else {
                    logs = logs.sorted(by: { $0.port > $1.port })
                }
            }
            if indexPath.column == 9 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.protocolNetwork < $1.protocolNetwork })
                } else {
                    logs = logs.sorted(by: { $0.protocolNetwork > $1.protocolNetwork })
                }
            }
            if indexPath.column == 10 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.ipAddress < $1.ipAddress })
                } else {
                    logs = logs.sorted(by: { $0.ipAddress > $1.ipAddress })
                }
            }
            
            spreadsheetView.reloadData()
        }
        
        // IP address
        if indexPath.column == 10 && indexPath.row != 0 {
            let ip = logs[indexPath.row - 1].ipAddress
            if ip == "" { return }
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
    
}
