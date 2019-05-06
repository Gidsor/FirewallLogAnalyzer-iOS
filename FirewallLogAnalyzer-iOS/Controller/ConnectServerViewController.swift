//
//  ConnectServerViewController.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 03/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

class ConnectServerViewController: UIViewController {
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func connect(_ sender: Any) {
        if urlTextField.text != "" && passwordTextField.text != "" {
            if let server = urlTextField.text, server.isIPAddress() {
                var serverURL = "http://\(server)"
                if let port = portTextField.text, port != "" {
                    serverURL.append(":\(port)")
                }
                UserSettings.server = serverURL
                UserSettings.password = passwordTextField.text
                (UIApplication.shared.delegate as? AppDelegate)?.setRootViewController(storyboardName: "Main", viewControlellerIdentifier: "MainTabBarController")
            }
        }
    }
}
