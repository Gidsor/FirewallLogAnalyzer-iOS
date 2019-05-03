//
//  DashboardTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 03/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class DashboardTableViewController: UITableViewController {
    @IBOutlet weak var kasperskyCell: UITableViewCell!
    @IBOutlet weak var tplinkCell: UITableViewCell!
    @IBOutlet weak var dlinkCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    func updateDashboard() {
    }
}
