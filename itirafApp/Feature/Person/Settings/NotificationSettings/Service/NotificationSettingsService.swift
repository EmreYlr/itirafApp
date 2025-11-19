//
//  NotificationSettingsService.swift
//  itirafApp
//
//  Created by Emre on 19.11.2025.
//

import Alamofire

protocol NotificationSettingsServiceProtocol {
    func getNotificationPreferences() async throws -> NotificationPreferences
    func updateNotificationPreferences(request: NotificationPreferencesUpdateRequest) async throws
}

final class NotificationSettingsService: NotificationSettingsServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func getNotificationPreferences() async throws -> NotificationPreferences {
        return try await networkService.request(
            endpoint: Endpoint.User.getNotificationPreferences,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
        )
    }
    
    func updateNotificationPreferences(request: NotificationPreferencesUpdateRequest) async throws {
        let parameters = try request.asDictionary()
        
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.User.editNotificationPreferences,
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
    
}
