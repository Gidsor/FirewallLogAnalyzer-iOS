//
//  Log.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 02/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

enum FirewallType: String {
    case kaspersky = "Kaspersky"
    case tplink = "TPLink"
    case dlink = "DLink"
    case unknown
}

class Log {
    var id: Int
    var time: String
    var date: String
    var firewallType: FirewallType
    
    init(json: JSON) {
        id = json["id"] as? Int ?? 0
        time = json["time"] as? String ?? ""
        date = json["date"] as? String ?? ""
        
        let type = json["firewallType"] as? String ?? ""
        if type == FirewallType.kaspersky.rawValue {
            firewallType = .kaspersky
        } else if type == FirewallType.tplink.rawValue {
            firewallType = .tplink
        } else if type == FirewallType.dlink.rawValue {
            firewallType = .dlink
        } else {
            firewallType = .unknown
        }
    }
}
