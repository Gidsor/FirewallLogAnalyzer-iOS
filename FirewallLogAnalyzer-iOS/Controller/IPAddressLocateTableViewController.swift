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
        setupKeyboard()
    }
    
    func setupKeyboard() {
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        ipTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction() {
        view.endEditing(true)
    }
    
    @IBAction func search(_ sender: Any) {
        guard let ip = ipTextField.text else { return }
        self.view.endEditing(true)
        NetworkManager.shared.getLocation(ip: ip) { (status, ipGeoLocation) in
            
        }
    }
}
