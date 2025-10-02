//
//  UserDefaultsHelper.swift
//  itirafApp
//
//  Created by Emre on 1.10.2025.
//

import Foundation

extension UserDefaults {
    func string(forKey key: Keys) -> String? {
        return string(forKey: key.rawValue)
    }
    
    func set(_ value: String?, forKey key: Keys) {
        set(value, forKey: key.rawValue)
    }
    
    func bool(forKey key: Keys) -> Bool {
        return bool(forKey: key.rawValue)
    }
    
    func set(_ value: Bool, forKey key: Keys) {
        set(value, forKey: key.rawValue)
    }
    
    func set(_ value: Data?, forKey key: Keys) {
        set(value, forKey: key.rawValue)
    }
    
    func data(forKey key: Keys) -> Data? {
        return data(forKey: key.rawValue)
    }
    
    func removeObject(forKey key: Keys) {
        removeObject(forKey: key.rawValue)
    }
}
