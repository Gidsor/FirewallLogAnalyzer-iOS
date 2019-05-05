//
//  Log.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 05/05/2019.
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
    var formatterDate: Date?
    var firewallType: FirewallType
    
    init(json: JSON) {
        id = json["id"] as? Int ?? 0
        time = json["time"] as? String ?? ""
        date = json["date"] as? String ?? ""
        
        let type = json["firewallType"] as? String ?? ""
        if type == FirewallType.kaspersky.rawValue {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale.current
            formatterDate = formatter.date(from: date + " " + time)
            firewallType = .kaspersky
        } else if type == FirewallType.tplink.rawValue {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale.current
            formatterDate = formatter.date(from: date + " " + time)
            firewallType = .tplink
        } else if type == FirewallType.dlink.rawValue {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale.current
            formatterDate = formatter.date(from: date + " " + time)
            firewallType = .dlink
        } else {
            firewallType = .unknown
        }
    }
}
