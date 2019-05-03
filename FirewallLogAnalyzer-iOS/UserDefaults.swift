//
//  UserDefaults.swift
//  FirewallLogAnalyzer-iOS
//
//  Created by Vadim Denisov on 21/04/2019.
//  Copyright © 2019 Vadim Denisov. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    
    // IP address/URL
    case server = "kServer"
    // TODO: save password to private storage keychain
    case password = "kPasswordk"
}

struct UserSettings {
    
    /// User identifier.
    static var server: String? {
        get {
            return UserDefaultsSyncAccess.shared.getUserDefaults(key: .server) as? String
        }
        set {
            UserDefaultsSyncAccess.shared.setUserDefaults(key: .server , obj: newValue as AnyObject)
        }
    }
    static var password: String? {
        get {
            return UserDefaultsSyncAccess.shared.getUserDefaults(key: .password) as? String
        }
        set {
            UserDefaultsSyncAccess.shared.setUserDefaults(key: .password , obj: newValue as AnyObject)
        }
    }
}

class UserDefaultsSyncAccess {
    
    static let shared = UserDefaultsSyncAccess()
    
    private let accessQueue = DispatchQueue(label: "User Defaults Synchronize Queue")
    
    func setUserDefaults(key: UserDefaultsKey, obj: AnyObject) {
        accessQueue.sync {
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: obj)
            let defaults = UserDefaults.standard
            defaults.set(encodedData, forKey: key.rawValue)
            defaults.synchronize()
        }
    }
    
    func getUserDefaults(key: UserDefaultsKey) -> AnyObject? {
        let closure: (UserDefaultsKey) -> AnyObject? = { (key) in
            self.accessQueue.sync {
                let data = UserDefaults.standard.value(forKey: key.rawValue)
                
                if let dataUnwrapped = data as? Data {
                    return NSKeyedUnarchiver.unarchiveObject(with: dataUnwrapped) as AnyObject
                } else {
                    return nil
                }
            }
        }
        return closure(key)
    }
}

class UserDefaultsObserver: NSObject {
    
    private let syncAccess = UserDefaultsSyncAccess()
    
    private var observers: [String : NSNotification.Name] = [:]
    
    deinit {
        for observer in observers {
            UserDefaults.standard.removeObserver(self, forKeyPath: observer.key)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let name = observers[keyPath], let key = UserDefaultsKey(rawValue: keyPath) else {
            return
        }
        
        NotificationCenter.default.post(name: name, object: syncAccess.getUserDefaults(key: key))
    }
    
    public func add<T>(forKey key: UserDefaultsKey, as type: T.Type, response: @escaping (T?) -> Void) {
        UserDefaults.standard.addObserver(self, forKeyPath: key.rawValue, options: [.new], context: nil)
        
        let name = Notification.Name(rawValue: "UserDefaults Observer for \(key)")
        observers[key.rawValue] = name
        
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            response(notification.object as? T)
        }
    }
    
    public func remove(forKey key: UserDefaultsKey) {
        UserDefaults.standard.removeObserver(self, forKeyPath: key.rawValue)
        NotificationCenter.default.removeObserver(self, name: observers[key.rawValue], object: nil)
        observers.removeValue(forKey: key.rawValue)
    }
}
