//
//  SearchDLinkReportTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 10/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit
import SpreadsheetView

class SearchDLinkReportTableViewController: UITableViewController {

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
    var logs: [DLinkLog] = []
    
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

extension SearchDLinkReportTableViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 24
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
            if indexPath.column == 12 {
                cell.label.text = "Source Port"
            }
            if indexPath.column == 13 {
                cell.label.text = "Destination Port"
            }
            if indexPath.column == 14 {
                cell.label.text = "Event"
            }
            if indexPath.column == 15 {
                cell.label.text = "Action"
            }
            if indexPath.column == 16 {
                cell.label.text = "Connection"
            }
            if indexPath.column == 17 {
                cell.label.text = "Connection New Src IP"
            }
            if indexPath.column == 18 {
                cell.label.text = "Connection New Src Port"
            }
            if indexPath.column == 19 {
                cell.label.text = "Connection New Dst IP"
            }
            if indexPath.column == 20 {
                cell.label.text = "Connection New Dst Port"
            }
            if indexPath.column == 21 {
                cell.label.text = "OrigSent"
            }
            if indexPath.column == 22 {
                cell.label.text = "TermSent"
            }
            if indexPath.column == 23 {
                cell.label.text = "Connection Time"
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
        if indexPath.column == 12 {
            cell.label.text = log.srcPort
        }
        if indexPath.column == 13 {
            cell.label.text = log.dstPort
        }
        if indexPath.column == 14 {
            cell.label.text = log.event
        }
        if indexPath.column == 15 {
            cell.label.text = log.action
        }
        if indexPath.column == 16 {
            cell.label.text = log.conn
        }
        if indexPath.column == 17 {
            cell.label.text = log.connNewSrcIP
        }
        if indexPath.column == 18 {
            cell.label.text = log.connNewSrcPort
        }
        if indexPath.column == 19 {
            cell.label.text = log.connNewDstIP
        }
        if indexPath.column == 20 {
            cell.label.text = log.connNewDstPort
        }
        if indexPath.column == 21 {
            cell.label.text = log.origSent
        }
        if indexPath.column == 22 {
            cell.label.text = log.termSent
        }
        if indexPath.column == 23 {
            cell.label.text = log.connTime
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
        if column == 14 {
            return 160
        }
        if column == 17 {
            return 120
        }
        if column == 18 {
            return 130
        }
        if column == 19 {
            return 120
        }
        if column == 20 {
            return 130
        }
        if column == 23 {
            return 90
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
                    logs = logs.sorted(by: { $0.severity < $1.severity })
                } else {
                    logs = logs.sorted(by: { $0.severity > $1.severity })
                }
            }
            if indexPath.column == 4 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.category < $1.category })
                } else {
                    logs = logs.sorted(by: { $0.category > $1.category })
                }
            }
            if indexPath.column == 5 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.categoryID < $1.categoryID })
                } else {
                    logs = logs.sorted(by: { $0.categoryID > $1.categoryID })
                }
            }
            if indexPath.column == 6 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.rule < $1.rule })
                } else {
                    logs = logs.sorted(by: { $0.rule > $1.rule })
                }
            }
            if indexPath.column == 7 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.protocolNetwork < $1.protocolNetwork })
                } else {
                    logs = logs.sorted(by: { $0.protocolNetwork > $1.protocolNetwork })
                }
            }
            if indexPath.column == 8 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.srcIf < $1.srcIf })
                } else {
                    logs = logs.sorted(by: { $0.srcIf > $1.srcIf })
                }
            }
            if indexPath.column == 9 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.dstIf < $1.dstIf })
                } else {
                    logs = logs.sorted(by: { $0.dstIf > $1.dstIf })
                }
            }
            if indexPath.column == 10 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.srcIP < $1.srcIP })
                } else {
                    logs = logs.sorted(by: { $0.srcIP > $1.srcIP })
                }
            }
            if indexPath.column == 11 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.srcPort < $1.srcPort })
                } else {
                    logs = logs.sorted(by: { $0.srcPort > $1.srcPort })
                }
            }
            if indexPath.column == 12 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.dstPort < $1.dstPort })
                } else {
                    logs = logs.sorted(by: { $0.dstPort > $1.dstPort })
                }
            }
            if indexPath.column == 13 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.dstPort < $1.dstPort })
                } else {
                    logs = logs.sorted(by: { $0.dstPort > $1.dstPort })
                }
            }
            if indexPath.column == 14 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.event < $1.event })
                } else {
                    logs = logs.sorted(by: { $0.event > $1.event })
                }
            }
            if indexPath.column == 15 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.action < $1.action })
                } else {
                    logs = logs.sorted(by: { $0.action > $1.action })
                }
            }
            if indexPath.column == 16 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.conn < $1.conn })
                } else {
                    logs = logs.sorted(by: { $0.conn > $1.conn })
                }
            }
            if indexPath.column == 17 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.connNewSrcIP < $1.connNewSrcIP })
                } else {
                    logs = logs.sorted(by: { $0.connNewSrcIP > $1.connNewSrcIP })
                }
            }
            if indexPath.column == 18 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.connNewSrcPort < $1.connNewSrcPort })
                } else {
                    logs = logs.sorted(by: { $0.connNewSrcPort > $1.connNewSrcPort })
                }
            }
            if indexPath.column == 19 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.connNewDstIP < $1.connNewDstIP })
                } else {
                    logs = logs.sorted(by: { $0.connNewDstIP > $1.connNewDstIP })
                }
            }
            if indexPath.column == 20 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.connNewDstPort < $1.connNewDstPort })
                } else {
                    logs = logs.sorted(by: { $0.connNewDstPort > $1.connNewDstPort })
                }
            }
            if indexPath.column == 21 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.origSent < $1.origSent })
                } else {
                    logs = logs.sorted(by: { $0.origSent > $1.origSent })
                }
            }
            if indexPath.column == 22 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.termSent < $1.termSent })
                } else {
                    logs = logs.sorted(by: { $0.termSent > $1.termSent })
                }
            }
            if indexPath.column == 23 {
                if sortedDirection == .ascending {
                    logs = logs.sorted(by: { $0.connTime < $1.connTime })
                } else {
                    logs = logs.sorted(by: { $0.connTime > $1.connTime })
                }
            }
            spreadsheetView.reloadData()
        }
        
        // IP address
        if indexPath.row != 0 {
            var ip = ""
            let log = logs[indexPath.row - 1]
            if indexPath.column == 10 { ip = log.srcIP }
            if indexPath.column == 11 { ip = log.dstIP }
            if indexPath.column == 17 { ip = log.connNewSrcIP }
            if indexPath.column == 19 { ip = log.connNewDstIP }
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
