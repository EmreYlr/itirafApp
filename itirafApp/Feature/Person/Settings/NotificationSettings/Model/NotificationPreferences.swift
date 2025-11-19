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
    case email = "email"
    case push = "push"
}

enum NotificationPreferencesChannel: String, Codable {
    case newMessage = "new_message"
    case newReply = "new_reply"
    case newLike = "new_like"
    case newDM = "new_dm"
    case dmRequest = "dm_request"
    case dmRequestResponse = "dm_request_response"
    case confessionModeration = "confession_moderation"
}

struct NotificationPreferencesUpdateRequest: Codable {
    let pushEnabled: Bool?
    let items: [NotificationPreferencesItem]?
}
