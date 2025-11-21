//
//  ModerationModel.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//

struct ModerationModel: Codable {
    var page, limit, totalRows, totalPages: Int
    var data: [ModerationData]
}

struct ModerationData: Codable, Hashable{
    let id: Int
    let title, message: String
    let channelID: Int
    let channelTitle, ownerID, ownerUsername: String
    let moderationStatus: ModerationStatus
    let rejectionReason: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, message
        case channelID = "channelId"
        case channelTitle
        case ownerID = "ownerId"
        case ownerUsername, moderationStatus, rejectionReason, createdAt
    }
    
    static func == (lhs: ModerationData, rhs: ModerationData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.moderationStatus == rhs.moderationStatus
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ModerationDecisionRequest: Codable {
    let messageID: Int
    let decision: ModerationDecision
    let violations: [Violation]?
    let rejectionReason: String?
    let notes: String?
}

enum ModerationDecision: String, Codable {
    case approve = "APPROVE"
    case reject = "REJECT"
}
