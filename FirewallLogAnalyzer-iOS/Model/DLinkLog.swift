//
//  DLinkLog.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 01/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

class DLinkLog {
    var id: Int
    var time: String
    var date: String
    var firewallType: FirewallType
    
    var severity: String
    var category: String
    var categoryID: String
    var rule: String
    var protocolNetwork: String
    var srcIf: String
    var dstIf: String
    var srcIP: String
    var dstIP: String
    var srcPort: String
    var dstPort: String
    var event: String
    var action: String
    
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
        
        severity = json["severity"] as? String ?? ""
        category = json["category"] as? String ?? ""
        categoryID = json["categoryID"] as? String ?? ""
        rule = json["rule"] as? String ?? ""
        protocolNetwork = json["proto"] as? String ?? ""
        srcIf = json["srcIf"] as? String ?? ""
        dstIf = json["dstIf"] as? String ?? ""
        srcIP = json["srcIP"] as? String ?? ""
        dstIP = json["dstIP"] as? String ?? ""
        srcPort = json["srcPort"] as? String ?? ""
        dstPort = json["dstPort"] as? String ?? ""
        event = json["event"] as? String ?? ""
        action = json["action"] as? String ?? ""
    }
    
    static func getLogs(json: JSON) -> [DLinkLog] {
        guard let results = json["results"] as? [JSON] else { return [] }
        
        var logs: [DLinkLog] = []
        for json in results {
            logs.append(DLinkLog(json: json))
        }
        
        return logs
    }
}
