//
//  BlockedUser.swift
//  itirafApp
//
//  Created by Emre on 16.02.2026.
//

struct BlockedUser: Codable, Hashable {
    let userID, username, blockedAt: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case username, blockedAt
    }
    
    static func == (lhs: BlockedUser, rhs: BlockedUser) -> Bool {
        return lhs.userID == rhs.userID &&
        lhs.username == rhs.username &&
        lhs.blockedAt == rhs.blockedAt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
    }
}
