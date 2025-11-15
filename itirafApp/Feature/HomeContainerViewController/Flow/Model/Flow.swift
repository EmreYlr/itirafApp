//
//  Flow.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

struct Flow: Codable {
    let page, limit, totalRows, totalPages: Int
    var data: [FlowData]
}

struct FlowData: Codable, Hashable{
    let id: Int
    let title, message: String
    var likeCount: Int
    var liked: Bool
    let replyCount: Int
    let createdAt: String
    let owner: Owner
    let channel: ChannelData
    
    static func == (lhs: FlowData, rhs: FlowData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.liked == rhs.liked &&
        lhs.likeCount == rhs.likeCount &&
        lhs.createdAt == rhs.createdAt &&
        lhs.likeCount == rhs.likeCount &&
        lhs.replyCount == rhs.replyCount
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
