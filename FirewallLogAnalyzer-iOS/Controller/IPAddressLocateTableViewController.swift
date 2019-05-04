//
//  IPAddressLocateTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 04/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class IPAddressLocateTableViewController: UITableViewController {
    @IBOutlet weak var ipTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }
    
    @IBAction func search(_ sender: Any) {
        guard let ip = ipTextField.text else { return }
        NetworkManager.shared.getLocation(ip: ip) { (status, json) in
            print(json)
        }
    }
}
