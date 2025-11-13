//
//  DirectMessage.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

struct DirectMessage: Hashable, Codable {
    let roomID, username, lastMessage, lastMessageDate: String
    let isLastMessageMine: Bool
    let status: String
    let unreadMessageCount: Int

    enum CodingKeys: String, CodingKey {
        case roomID = "roomId"
        case username, lastMessage, lastMessageDate, isLastMessageMine, status, unreadMessageCount
    }
    
    static func == (lhs: DirectMessage, rhs: DirectMessage) -> Bool {
        return lhs.roomID == rhs.roomID &&
        lhs.lastMessageDate == rhs.lastMessageDate &&
        lhs.lastMessage == rhs.lastMessage &&
        lhs.isLastMessageMine == rhs.isLastMessageMine &&
        lhs.unreadMessageCount == rhs.unreadMessageCount
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(roomID)
    }
}
