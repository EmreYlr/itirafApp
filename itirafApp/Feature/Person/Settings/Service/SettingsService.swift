//
//  SettingsService.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//
import Alamofire

protocol SettingsServiceProtocol {
    func logout(isAnonymous: Bool) async throws
}

final class SettingsService: SettingsServiceProtocol {
    private let networkService: NetworkService
    private let followManager: FollowManager
    
    init(networkService: NetworkService = NetworkManager.shared, followManager: FollowManager = FollowManager.shared) {
        self.networkService = networkService
        self.followManager = followManager
    }
    
    func logout(isAnonymous: Bool) async throws {
        defer {
            performLocalCleanup()
        }

        if !isAnonymous {
            let _: Empty = try await networkService.request(
                endpoint: Endpoint.Auth.logout,
                method: .delete,
                parameters: nil,
                encoding: URLEncoding.default
            )
        }
    }

    private func performLocalCleanup() {
        CrashlyticsManager.shared.setUserID("none")
        CrashlyticsManager.shared.isUserAnonymous(true)
        ClarityManager.shared.clearUser()
        AuthManager.shared.clearTokens()
        UserManager.shared.clear()
        followManager.clearCache()
    }
}
