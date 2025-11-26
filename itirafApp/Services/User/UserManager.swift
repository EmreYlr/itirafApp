//
//  UserManager.swift
//  itirafApp
//
//  Created by Emre on 2.10.2025.
//

import Foundation

final class UserManager {
    static let shared = UserManager()
    
    private init() {
        self.currentUser = loadFromDefaults()
    }
    
    private(set) var currentUser: User?
    
    func getUser() -> User? {
        return currentUser
    }
    
    func getUsername() -> String? {
        return currentUser?.username
    }
    
    func getUserID() -> String? {
        return currentUser?.id
    }
    
    func getUserEmail() -> String? {
        return currentUser?.email
    }
    
    func getUserRoles() -> [Role]? {
        return currentUser?.roles
    }
    
    func getSocialLinks() -> [Link]? {
        return currentUser?.socialLink
    }
    
    func getUserIsAnonymous() -> Bool {
        return currentUser?.anonymous ?? true
    }
    
    func hasRole(_ role: RoleType) -> Bool {
        currentUser?.roles.contains { $0.name == role } ?? false
    }
    
    func setUser(_ user: User) {
        self.currentUser = user
        saveToDefaults(user)
        // OPTIONEL: user değiştiğinde Home ekranına bildirim göndermek için
        // NotificationCenter.default.post(name: .userDidChange, object: nil)
    }
    
    func saveSocialLinks(_ links: [Link]) {
        guard var user = currentUser else { return }
        user.socialLink = links
        setUser(user)
    }
    
    func clearSocialLinks() {
        guard var user = currentUser else { return }
        user.socialLink = []
        setUser(user)
    }
 
    func updateSocialLink(_ link: Link) {
        guard var user = currentUser, var links = user.socialLink else { return }
        
        if let index = links.firstIndex(where: { $0.id == link.id }) {
            links[index] = link
            user.socialLink = links
            setUser(user)
        }
    }
    
    func removeSocialLink(_ link: Link) {
        guard var user = currentUser, var links = user.socialLink else { return }
        
        links.removeAll { $0.id == link.id }
        user.socialLink = links
        setUser(user)
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
