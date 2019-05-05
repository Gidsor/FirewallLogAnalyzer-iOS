//
//  KasperskyLog.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 01/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

enum FirewallType: String {
    case kaspersky = "Kaspersky"
    case tplink = "TPLink"
    case dlink = "DLink"
    case unknown
}

class KasperskyLog {
    var id: Int
    var time: String
    var date: String
    var firewallType: FirewallType
    
    var description: String
    var protectType: String
    var application: String
    var result: String
    var objectAttack: String
    var port: String
    var protocolNetwork: String
    var ipAddress: String
    
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
        
        description = json["description"] as? String ?? ""
        protectType = json["protectType"] as? String ?? ""
        application = json["application"] as? String ?? ""
        result = json["result"] as? String ?? ""
        objectAttack = json["objectAttack"] as? String ?? ""
        port = json["port"] as? String ?? ""
        protocolNetwork = json["protocol"] as? String ?? ""
        ipAddress = json["ipAddress"] as? String ?? ""
    }
    
    static func getLogs(json: JSON) -> [KasperskyLog] {
        guard let results = json["results"] as? [JSON] else { return [] }
        
        var logs: [KasperskyLog] = []
        for json in results {
            logs.append(KasperskyLog(json: json))
        }
        
        return logs
    }
}
