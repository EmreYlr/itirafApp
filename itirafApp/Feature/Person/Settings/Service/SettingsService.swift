//
//  SettingsService.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//
import Alamofire

protocol SettingsServiceProtocol {
    func logout() async throws
}

final class SettingsService: SettingsServiceProtocol {
    private let networkService: NetworkService
    private let followManager: FollowManager
    
    init(networkService: NetworkService = NetworkManager.shared, followManager: FollowManager = FollowManager.shared) {
        self.networkService = networkService
        self.followManager = followManager
    }
    
    func logout() async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Auth.logout,
            method: .delete,
            parameters: nil,
            encoding: URLEncoding.default
        )
        CrashlyticsManager.shared.setUserID("none")
        CrashlyticsManager.shared.isUserAnonymous(true)
        
        AuthManager.shared.clearTokens()
        UserManager.shared.clear()
        
        followManager.clearCache()        
    }
}
