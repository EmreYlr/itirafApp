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
    var likeCount, replyCount, shareCount: Int
    let createdAt: String
    let owner: Owner
    let channel: ChannelData
    var shortlink: String?
    var replies: [Reply]
    let isNsfw: Bool
}

struct Reply: Codable {
    let id: Int
    let message: String
    let owner: Owner
    let createdAt: String
}

struct ShortlinkResponse: Codable {
    let url: String
}
