//
//  ReportsTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 07/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class ReportsTableViewController: UITableViewController {
    
    var kasperskyLogs: [KasperskyLog] = []
    var tplinkLogs: [TPLinkLog] = []
    var dlinkLogs: [DLinkLog] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        update()
    }
    
    func update() {
        var kasperskyLoaded = false
        var tplinkLoaded = false
        var dlinkLoaded = false
        
//        showActivityIndicator(in: view)
        NetworkManager.shared.updateKasperskyLogFiles { (status, logs) in
            self.kasperskyLogs = logs
            kasperskyLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
            }
        }
        
        NetworkManager.shared.updateTPLinkLogFiles { (status, logs) in
            self.tplinkLogs = logs
            tplinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
            }
        }
        
        NetworkManager.shared.updateDLinkLogFiles { (status, logs) in
            self.dlinkLogs = logs
            dlinkLoaded = true
            if kasperskyLoaded && tplinkLoaded && dlinkLoaded {
                self.hideActivityIndicator(in: self.view)
            }
        }
    }
}
