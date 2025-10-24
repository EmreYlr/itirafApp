//
//  DirectMessage.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

struct DirectMessage: Hashable {
    let id: Int
    let senderUsername: String
    let senderId: String
    let receiverId: String
    let message: String
    let roomId: String
    let createdAt: String
    
    static func == (lhs: DirectMessage, rhs: DirectMessage) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
