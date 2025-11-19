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
    let channel: NotificationPreferencesChannel
    let enabled: Bool
}

enum NotificationPreferencesType: String, Codable {
    case email = "EMAIL"
    case push = "PUSH"
}

enum NotificationPreferencesChannel: String, Codable {
    case newMessage = "NEW_MESSAGE"
    case newReply = "NEW_REPLY"
    case newLike = "NEW_LIKE"
    case newDM = "NEW_DM"
    case dmRequest = "DM_REQUEST"
    case dmRequestResponse = "DM_REQUEST_RESPONSE"
    case confessionModeration = "CONFESSION_MODERATION"
}

struct NotificationPreferencesUpdateRequest: Codable {
    let pushEnabled: Bool?
    let items: [NotificationPreferencesItem]?
}
