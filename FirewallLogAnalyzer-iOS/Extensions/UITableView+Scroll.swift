//
//  UITableView+Scroll.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 05/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import UIKit

extension UITableView {
    func scrollToTop() {
        if numberOfRows(inSection: 0) > 0 {
            scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
