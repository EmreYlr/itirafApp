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
    var liked: Bool
    var likeCount, replyCount: Int
    let createdAt: String
    let owner: Owner
    var replies: [Reply]

    enum CodingKeys: String, CodingKey {
        case id, title, message, likeCount, replyCount, liked, owner, replies, createdAt
    }
}

struct Reply: Codable {
    let id: Int
    let message: String
    let owner: Owner
    let createdAt: String
}

