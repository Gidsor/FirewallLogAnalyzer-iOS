//
//  TPLinkLog.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 01/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

class TPLinkLog {
    var id: Int
    var time: String
    var date: String
    var firewallType: FirewallType
    
    var typeEvent: String
    var levelSignificance: String
    var logContent: String
    var macAddress: String
    var ipAddress: String
    var protocolNetwork: String
    
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
        
        typeEvent = json["typeEvent"] as? String ?? ""
        levelSignificance = json["levelSignificance"] as? String ?? ""
        logContent = json["logContent"] as? String ?? ""
        macAddress = json["macAddress"] as? String ?? ""
        ipAddress = json["ipAddress"] as? String ?? ""
        protocolNetwork = json["protocol"] as? String ?? ""
    }
    
    static func getLogs(json: JSON) -> [TPLinkLog] {
        guard let results = json["results"] as? [JSON] else { return [] }
        
        var logs: [TPLinkLog] = []
        for json in results {
            logs.append(TPLinkLog(json: json))
        }
        
        return logs
    }
}
