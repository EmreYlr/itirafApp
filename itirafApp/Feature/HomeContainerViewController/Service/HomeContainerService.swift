//
//  HomeContainerService.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//
import Alamofire

protocol HomeContainerServiceProtocol {
    func fetchNotificationStatus() async throws -> NotificationStatus
}

final class HomeContainerService: HomeContainerServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchNotificationStatus() async throws -> NotificationStatus {
        return try await networkService.request(
            endpoint: Endpoint.Notification.notificationStatus,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default
        )
    }
}
