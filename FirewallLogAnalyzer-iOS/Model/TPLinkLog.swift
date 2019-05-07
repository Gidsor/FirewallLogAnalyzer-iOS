//
//  TPLinkLog.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 01/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

class TPLinkLog: Log {
    var typeEvent: String
    var levelSignificance: String
    var logContent: String
    var macAddress: String
    var ipAddress: String
    var protocolNetwork: String
    var event: String
    
    static var logs: [TPLinkLog] = []
    
    override init(json: JSON) {
        typeEvent = json["typeEvent"] as? String ?? ""
        levelSignificance = json["levelSignificance"] as? String ?? ""
        logContent = json["logContent"] as? String ?? ""
        macAddress = json["macAddress"] as? String ?? ""
        ipAddress = json["ipAddress"] as? String ?? ""
        protocolNetwork = json["protocol"] as? String ?? ""
        event = json["event"] as? String ?? ""
        
        super.init(json: json)
    }
    
    static func getLogs(json: JSON) -> [TPLinkLog] {
        guard let results = json["results"] as? [JSON] else { return [] }
        
        var logs: [TPLinkLog] = []
        for json in results {
            logs.append(TPLinkLog(json: json))
        }
        
        TPLinkLog.logs = logs
        return logs
    }
}
