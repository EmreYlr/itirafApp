//
//  ChannelMessageReply.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//
import Foundation

struct ChannelMessageReply: Codable {
    var id: String
    var message: String
    var targetMessageId: String
    var ownerId: String
    var createdAt: Date
}
