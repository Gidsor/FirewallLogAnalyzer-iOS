//
//  ReportsTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 07/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class ReportsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTopIPAddress", let destination = segue.destination as? TopIPAddressTableViewController {
            destination.sourceLogs = sender as? [Log] ?? []
        }
    }
    
    @IBAction func showTopDlinkIPAddress(_ sender: Any) {
        showActivityIndicator(in: view)
        NetworkManager.shared.updateDLinkLogFiles { (status, logs) in
            self.performSegue(withIdentifier: "ShowTopIPAddress", sender: logs)
            self.hideActivityIndicator(in: self.view)
        }
    }
    
    @IBAction func showTopTPLinkIPAddess(_ sender: Any) {
        showActivityIndicator(in: view)
        NetworkManager.shared.updateTPLinkLogFiles { (status, logs) in
            self.performSegue(withIdentifier: "ShowTopIPAddress", sender: logs)
            self.hideActivityIndicator(in: self.view)
        }
    }
    
    @IBAction func showKasperskyIPAddess(_ sender: Any) {
        showActivityIndicator(in: view)
        NetworkManager.shared.updateKasperskyLogFiles { (status, logs) in
            self.performSegue(withIdentifier: "ShowTopIPAddress", sender: logs)
            self.hideActivityIndicator(in: self.view)
        }
    }
}
