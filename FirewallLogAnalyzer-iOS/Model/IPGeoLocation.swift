//
//  IPGeoLocation.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 04/05/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

class IPGeoLocation {
    var ip: String = ""
    var hostname: String = ""
    var type: String = ""
    var continentCode: String = ""
    var continentName: String = ""
    var countryCode: String = ""
    var countryName: String = ""
    var regionCode: String = ""
    var regionName: String = ""
    var city: String = ""
    var zip: String = ""
    var latitude: String = ""
    var longitude: String = ""
    
    var geonameId: String = ""
    var capital: String = ""
    var countryFlag: String = ""
    var countryFlagEmoji: String = ""
    var countryFlagEmojiUnicode: String = ""
    var callingCode: String = ""
    
    struct Language {
        var code: String = ""
        var name: String = ""
        var native: String = ""
    }
    
    var languages: [Language] = []
    
    init(json: JSON) {
        ip = json["ip"] as? String ?? ""
        hostname = json["hostname"] as? String ?? ""
        type = json["type"] as? String ?? ""
        
        continentCode = json["continent_code"] as? String ?? ""
        continentName = json["continent_name"] as? String ?? ""
        countryCode = json["country_code"] as? String ?? ""
        countryName = json["country_name"] as? String ?? ""
        regionCode = json["region_code"] as? String ?? ""
        regionName = json["region_name"] as? String ?? ""
        city = json["city"] as? String ?? ""
        zip = json["zip"] as? String ?? ""
        latitude = json["latitude"] as? String ?? ""
        longitude = json["longitude"] as? String ?? ""
        
        if let json = json["location"] as? JSON {
            geonameId = json["geoname_id"] as? String ?? ""
            capital = json["capital"] as? String ?? ""
            countryFlag = json["country_flag"] as? String ?? ""
            countryFlagEmoji = json["country_flag_emoji"] as? String ?? ""
            countryFlagEmojiUnicode = json["country_flag_emoji_unicode"] as? String ?? ""
            callingCode = json["calling_code"] as? String ?? ""
            for json in json["languages"] as? [JSON] ?? [] {
                let code = json["code"] as? String ?? ""
                let name = json["name"] as? String ?? ""
                let native = json["native"] as? String ?? ""
                languages.append(Language(code: code, name: name, native: native))
            }
        }
    }
}
