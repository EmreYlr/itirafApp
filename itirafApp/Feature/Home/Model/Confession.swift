//
//  Confession.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

struct Confession: Codable, Identifiable {
    var id: String
    var title: String
    var message: String
    var likeCount: Int
    var channelId: Int
    var ownerId: String
    var isLiked: Bool = false
}
