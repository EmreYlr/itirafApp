//
//  Channel.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import Foundation

// MARK: - Channel
struct Channel: Codable {
    var page, limit, totalRows, totalPages: Int
    var data: [ChannelData]
}

struct ChannelData: Codable, Equatable, Hashable {
    let id: Int
    let title, description: String
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case imageURL = "imageUrl"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ChannelData, rhs: ChannelData) -> Bool {
        return lhs.id == rhs.id
    }
}
