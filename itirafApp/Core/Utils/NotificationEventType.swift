//
//  NotificationEventType.swift
//  itirafApp
//
//  Created by Emre on 20.11.2025.
//

import Foundation

enum NotificationEventType: String, Codable {
    case dmReceived = "DM_RECEIVED"
    case confessionReplied = "CONFESSION_REPLIED"
    case confessionLiked = "CONFESSION_LIKED"
    case confessionPublished = "CONFESSION_PUBLISHED"
    case dmRequestReceived = "DM_REQUEST_RECEIVED"
    case dmRequestResponded = "DM_REQUEST_RESPONDED"
    case confessionModerated = "CONFESSION_MODERATED"
    case adminReviewRequired = "ADMIN_REVIEW_REQUIRED"
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try NotificationEventType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

struct NotificationData: Decodable {
    let roomId: String?
    let requestId: String?
    let senderName: String?
    let senderId: String?
    let messageId: String?
    let commentId: String?
    let status: NotificationEventStatus?
    let notificationId: String?
}

struct NotificationPayloadWrapper: Decodable {
    let eventType: NotificationEventType
    let data: NotificationData
}

enum NotificationEventStatus: String, Codable {
    case accepted = "ACCEPTED"
    case rejected = "REJECTED"
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try NotificationEventStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
