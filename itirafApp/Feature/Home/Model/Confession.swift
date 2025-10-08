//
//  Confession.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

// MARK: - Confession
struct Confession: Codable {
    var page, limit, totalRows, totalPages: Int
    var data: [ConfessionData]
}

// MARK: - Datum
struct ConfessionData: Codable {
    let id: Int
    let title, message: String
    let likeCount, replyCount: Int
    let createdAt: String
    let owner: Owner

    enum CodingKeys: String, CodingKey {
        case id, title, message, likeCount, replyCount
        case createdAt = "created_at"
        case owner
    }
}

// MARK: - Owner
struct Owner: Codable {
    let id: String
}
