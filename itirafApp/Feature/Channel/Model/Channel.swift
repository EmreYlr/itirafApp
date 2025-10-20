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

// MARK: - Datum
struct ChannelData: Codable {
    let id: Int
    let title, description: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case imageURL = "imageUrl"
    }
}
