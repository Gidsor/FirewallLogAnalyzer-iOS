//
//  UIViewController+Alerts.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 13/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

enum AlertType {
    case noInternetConnection
}

extension UIViewController {
    
    func showAlert(title: String? = nil, message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    func showAlert(type: AlertType) {
        switch type {
        case .noInternetConnection:
            showAlert(title: "There are problems with connecting to the server", message: "Check internet connnection or application server")
        }
    }
    
}
