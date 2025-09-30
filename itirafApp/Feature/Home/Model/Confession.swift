//
//  Confession.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

struct Confession: Codable, Identifiable {
    var id: String
    var text: String
    var likes: Int
    var comments: Int
    var isLiked: Bool = false
}
