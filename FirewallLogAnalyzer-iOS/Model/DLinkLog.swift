//
//  DLinkLog.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 01/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

class DLinkLog: Log {
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
    
    override init(json: JSON) {
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
        
        super.init(json: json)
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
