//
//  Confession.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import Foundation

// MARK: - Confession
struct Confession: Codable {
    var page, limit, totalRows, totalPages: Int
    var data: [ConfessionData]
}

// MARK: - ConfessionData
struct ConfessionData: Codable, Hashable {
    let id: Int
    let title, message: String
    var liked: Bool
    var likeCount, replyCount: Int
    let createdAt: String
    let owner: Owner
    let channel: ChannelData?

    enum CodingKeys: String, CodingKey {
        case id, title, message, likeCount, replyCount, liked, createdAt, channel
        case owner
    }
    
    static func == (lhs: ConfessionData, rhs: ConfessionData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.liked == rhs.liked &&
        lhs.likeCount == rhs.likeCount &&
        lhs.channel == rhs.channel
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Owner
struct Owner: Codable {
    let id: String
    let username: String?
}
