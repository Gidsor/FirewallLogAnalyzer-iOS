//
//  String+Validation.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 06/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

extension String {
    func isIPAddress() -> Bool {
        return isIPv4() || isIPv6()
    }
    
    func isIPv4() -> Bool {
        let items = components(separatedBy: ".")
        if(items.count != 4) { return false }
        for item in items {
            var tmp = 0
            if (item.count > 3 || item.count < 1) { return false }
            for char in item{
                if (char < "0" || char > "9") { return false }
                tmp = tmp * 10 + Int(String(char))!
            }
            if (tmp < 0 || tmp > 255) { return false }
            if ((tmp > 0 && item.first == "0") || (tmp == 0 && item.count > 1)) {
                return false
            }
        }
        return true
    }
    
    func isIPv6() -> Bool {
        let items = components(separatedBy: ":")
        if (items.count != 8) { return false }
        for item in items {
            if (item.count > 4 || item.count < 1) { return false }
            for char in item.lowercased(){
                if ((char < "0" || char > "9") && (char < "a" || char > "f")) {
                    return false
                }
            }
        }
        return true
    }
}
