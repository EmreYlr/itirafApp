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

    enum CodingKeys: String, CodingKey {
        case roomID = "roomId"
        case username, lastMessage, lastMessageDate, isLastMessageMine, status
    }
    
    static func == (lhs: DirectMessage, rhs: DirectMessage) -> Bool {
        return lhs.roomID == rhs.roomID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(roomID)
    }
}
