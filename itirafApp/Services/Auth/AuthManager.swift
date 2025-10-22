//
//  AuthManager.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"

    func saveTokens(accessToken: String, refreshToken: String) {
        KeychainHelper.shared.saveToKeychain(key: self.accessTokenKey, value: accessToken)
        KeychainHelper.shared.saveToKeychain(key: self.refreshTokenKey, value: refreshToken)
        
    }

    func getAccessToken() -> String? {
        return KeychainHelper.shared.readFromKeychain(key: accessTokenKey)
    }

    func getRefreshToken() -> String? {
        return KeychainHelper.shared.readFromKeychain(key: refreshTokenKey)
    }

    func clearTokens() {
        KeychainHelper.shared.deleteFromKeychain(key: accessTokenKey)
        KeychainHelper.shared.deleteFromKeychain(key: refreshTokenKey)
    }

    var isLoggedIn: Bool {
        return getAccessToken() != nil
    }
    
}
