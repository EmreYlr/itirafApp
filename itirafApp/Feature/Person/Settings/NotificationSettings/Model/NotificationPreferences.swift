//
//  NotificationPreferences.swift
//  itirafApp
//
//  Created by Emre on 19.11.2025.
//

struct NotificationPreferences: Codable {
    let id, userID: String
    let pushEnabled, emailEnabled: Bool
    let items: [NotificationPreferencesItem]

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case pushEnabled, emailEnabled, items
    }
}

// MARK: - Item
struct NotificationPreferencesItem: Codable {
    let notificationType: NotificationPreferencesType
    let eventType: NotificationEventType
    var enabled: Bool
}

enum NotificationPreferencesType: String, Codable {
    case email = "EMAIL"
    case push = "PUSH"
}

struct NotificationPreferencesUpdateRequest: Codable {
    let pushEnabled: Bool?
    let items: [NotificationPreferencesItem]?
}
