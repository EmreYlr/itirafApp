//
//  ChannelMessageData.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//
import Foundation

struct ChannelMessageData: Codable {
    let id: Int
    let title, message: String
    let liked: Bool
    let likeCount, replyCount: Int
    let createdAt: String
    let owner: Owner
    let replies: [Reply]

    enum CodingKeys: String, CodingKey {
        case id, title, message, likeCount, replyCount, liked, owner, replies
        case createdAt = "created_at"
    }
}

struct Reply: Codable {
    let id: Int
    let message: String
    let owner: Owner
}

