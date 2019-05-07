//
//  KasperskyLog.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 01/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

class KasperskyLog: Log {
    var description: String
    var protectType: String
    var application: String
    var result: String
    var objectAttack: String
    var port: String
    var protocolNetwork: String
    var ipAddress: String
    
    static var logs: [KasperskyLog] = []
    
    override init(json: JSON) {
        description = json["description"] as? String ?? ""
        protectType = json["protectType"] as? String ?? ""
        application = json["application"] as? String ?? ""
        result = json["result"] as? String ?? ""
        objectAttack = json["objectAttack"] as? String ?? ""
        port = json["port"] as? String ?? ""
        protocolNetwork = json["protocol"] as? String ?? ""
        ipAddress = json["ipAddress"] as? String ?? ""
        
        super.init(json: json)
    }
    
    static func getLogs(json: JSON) -> [KasperskyLog] {
        guard let results = json["results"] as? [JSON] else { return [] }
        
        var logs: [KasperskyLog] = []
        for json in results {
            logs.append(KasperskyLog(json: json))
        }
        
        KasperskyLog.logs = logs
        return logs
    }
}
