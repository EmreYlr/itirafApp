//
//  UserManager.swift
//  itirafApp
//
//  Created by Emre on 2.10.2025.
//

import Foundation

final class UserManager {
    static let shared = UserManager()
    private init() {}
    
    private(set) var currentUser: User?
    
    func getUser() -> User? {
        if currentUser == nil {
            currentUser = loadFromDefaults()
        }
        return currentUser
    }

    
    func getUserEmail() -> String? {
        return currentUser?.email
    }
    
    func getUserIsAnonymous() -> Bool {
        return currentUser?.anonymous ?? false
    }
    
    func setUser(_ user: User) {
        self.currentUser = user
        saveToDefaults(user)
    }
    
    private func loadUser() {
        if let saved = loadFromDefaults() {
            self.currentUser = saved
        }
    }
    
    func clear() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: .currentUser)
    }
    
    private func saveToDefaults(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: .currentUser)
        }
    }
    
    private func loadFromDefaults() -> User? {
        guard let data = UserDefaults.standard.data(forKey: .currentUser),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
}
