//
//  Message.swift
//  itirafApp
//
//  Created by Emre on 23.10.2025.
//

import Foundation
import MessageKit

// MARK: - RoomMessages
struct RoomMessages: Codable {
    var page, limit, totalRows, totalPages: Int
    var data: [MessageData]
}

// MARK: - MessageData
struct MessageData: Codable {
    var id: Int
    var content, createdAt: String
    var isMyMessage, seen: Bool
}

//MessagKit Models
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

