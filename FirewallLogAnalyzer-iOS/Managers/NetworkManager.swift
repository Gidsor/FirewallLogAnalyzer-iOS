//
//  NetworkManager.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 23/04/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Alamofire

enum Server: String {
//    case development = "http://localhost:8000"
    case development = "http://192.168.0.105:8000"
//    case production = "http://localhost:8000"
}

enum StatusCode: Int, Error {
    case ok = 200
    case created = 201
    case noContent = 204
    case imUsed = 226
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case expectationFailed = 417
    case toManyRequests = 429
    case internalServerError = 500
    case unknown
    
    init(unsafeRawValue: Int?) {
        if let unsafeRawValue = unsafeRawValue, let error = StatusCode(rawValue: unsafeRawValue) {
            self = error
        } else {
            self = .unknown
        }
    }
}

enum Path: String {
    case update = "/api/logfiles/update"
    case updateKaspersky = "/api/logfiles/update/kaspersky"
    case updateTPLink = "/api/logfiles/update/tplink"
    case updateDLink = "/api/logfiles/update/dlink"
    
    case logfilesKaspersky = "/api/logfiles/kaspersky"
    case logfilesTPLink = "/api/logfiles/tplink"
    case logfilesDLink = "/api/logfiles/dlink"
}

typealias JSON = [String : Any]
typealias Response = (StatusCode, JSON?) -> Void

class NetworkManager {
    let queue = DispatchQueue(label: "Network Manger Queue", qos: .utility)
    
    static let shared = NetworkManager()
    
    #if DEBUG
    let hostname = Server.development.rawValue
    #else
    let hostname = Server.development.rawValue
    #endif
    
    private init() {}
    
    @discardableResult
    private func makeCall(path: Path, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil, response: @escaping Response) -> DataRequest {
        return makeCall(path: path.rawValue, method: method, parameters: parameters, encoding: encoding, headers: headers) { (statusCode, json) in
            response(statusCode, json)
        }
    }
    
    @discardableResult
    private func makeCall(path: String, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders? = nil, response: @escaping Response) -> DataRequest {
        let urlString = (hostname + path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return Alamofire.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseData(queue: queue, completionHandler: { (responseData) in
            DispatchQueue.main.async {
                print("\nSHORTLOG (Call: \(path), Method: \(method), Parameters: \(parameters ?? [:]), Headers: \(headers ?? [:]), Result: \(responseData.result.description))")
                let statusCode = StatusCode(unsafeRawValue: responseData.response?.statusCode)
                switch responseData.result {
                case .success:
                    if let data = responseData.data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                        if json is NSArray {
                            let json = ["results" : json]
                            response(statusCode, json)
                        } else {
                            response(statusCode, json as? JSON)
                        }
                        switch statusCode {
                        case .ok:
                            print("STATUS CODE: OK")
                        case .created:
                            print("STATUS CODE: Created")
                        case .noContent:
                            print("STATUS CODE: No Content")
                        case .imUsed:
                            print("STATUS CODE: IM Used")
                        case .badRequest:
                            print("ERROR: Bad Request")
                        case .forbidden:
                            print("ERROR: Forbidden")
                        case .expectationFailed:
                            print("ERROR: Expection Failed")
                        case .internalServerError:
                            print("ERROR: Internal Server Error")
                        case .unauthorized:
                            print("ERROR: Unauthorized")
                        case .toManyRequests:
                            print("ERROR: Too many requests")
                        case .unknown:
                            print("ERROR: Unknow code from \(json)")
                            
                        }
                    } else {
                        response(statusCode, nil)
                        print("ERROR: Unable get json object from data. STATUS CODE: \(statusCode)")
                    }
                case .failure(let error):
                    if let data = responseData.data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                        response(statusCode, json)
                    } else {
                        response(statusCode, nil)
                    }
                    print("ERROR: \(error.localizedDescription)")
                }
            }
        })
    }
    
    func updateLogFiles(response: Response? = nil) {
        makeCall(path: .update, method: .get) { (statusCode, json) in
            if let response = response {
                response(statusCode, json)
            }
        }
    }
    
    func updateKasperskyLogFiles(response: Response? = nil) {
        makeCall(path: .updateKaspersky, method: .get) { (statusCode, json) in
            if let response = response {
                response(statusCode, json)
            }
        }
    }
    
    func updateTPLinkLogFiles(response: Response? = nil) {
        makeCall(path: .updateTPLink, method: .get) { (statusCode, json) in
            if let response = response {
                response(statusCode, json)
            }
        }
    }
    
    func updateDLinkLogFiles(response: Response? = nil) {
        makeCall(path: .updateDLink, method: .get) { (statusCode, json) in
            if let response = response {
                response(statusCode, json)
            }
        }
    }
    
    func getKasperskyLogFiles(response: @escaping Response) {
        makeCall(path: .logfilesKaspersky, method: .get) { (statusCode, json) in
            response(statusCode, json)
        }
    }
    
    func getTPLinkLogFiles(response: @escaping Response) {
        makeCall(path: .logfilesTPLink, method: .get) { (statusCode, json) in
            response(statusCode, json)
        }
    }
    
    func getDLinkLogFiles(response: @escaping Response) {
        makeCall(path: .logfilesDLink, method: .get) { (statusCode, json) in
            response(statusCode, json)
        }
    }
}
