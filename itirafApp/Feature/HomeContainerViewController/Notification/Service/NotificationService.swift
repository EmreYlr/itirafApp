//
//  NotificationService.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//
import Alamofire

protocol NotificationServiceProtocol {
    func listAllNotifications(page: Int, limit: Int) async throws -> NotificationModel
    func seenAllNotifications() async throws
    func deleteNotification(notificationIDS: [String]) async throws
    func deleteAllNotifications() async throws
}

final class NotificationService: NotificationServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func listAllNotifications(page: Int, limit: Int) async throws -> NotificationModel {
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        return try await networkService.request(
            endpoint: Endpoint.Notification.listAllNotificioations,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
        )
    }
    
    func seenAllNotifications() async throws {
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.Notification.seenAllNotifications,
            method: .put,
            parameters: nil,
            encoding: JSONEncoding.default,
        )
    }
    
    func deleteNotification(notificationIDS: [String]) async throws {
        let parameters: [String: Any] = [
            "notificationIds": notificationIDS
        ]
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.Notification.deleteNotifications,
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default,
        )
    }
    
    func deleteAllNotifications() async throws {
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.Notification.deleteAllNotifications,
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default,
        )
    }
}
