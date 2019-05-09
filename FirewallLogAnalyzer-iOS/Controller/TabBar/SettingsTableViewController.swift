//
//  SettingsTableViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 04/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            logout()
        }
    }
    
    func logout() {
        UserSettings.server = nil
        UserSettings.password = nil
        (UIApplication.shared.delegate as? AppDelegate)?.setRootViewController(storyboardName: "Main", viewControlellerIdentifier: "ConnectServerViewController")
    }
}
