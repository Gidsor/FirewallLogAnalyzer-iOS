//
//  ConnectedServersTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 07/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class ConnectedServersTableViewController: UITableViewController {
    @IBOutlet weak var serverCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        serverCell.textLabel?.text = UserSettings.server
    }

}
