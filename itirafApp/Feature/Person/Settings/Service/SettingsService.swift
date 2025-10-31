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
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func logout() async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Auth.logout,
            method: .delete,
            parameters: nil,
            encoding: URLEncoding.default
        )
        AuthManager.shared.clearTokens()
        UserManager.shared.clear()
    }
}
