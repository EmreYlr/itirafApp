//
//  MyConfession.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

struct MyConfession: Codable {
    var page, limit, totalRows, totalPages: Int
    var data: [MyConfessionData]
}

// MARK: - MyConfessionData
struct MyConfessionData: Codable, Hashable {
    let id: Int
    let title, message: String
    let likeCount: Int
    let liked: Bool
    let replyCount: Int
    let createdAt: String
    let owner: Owner
    let rejectionReason: String?
    let moderationStatus: ModerationStatus
    
    static func == (lhs: MyConfessionData, rhs: MyConfessionData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.message == rhs.message
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum ModerationStatus: String, Codable {
    case humanApproved = "HUMAN_APPROVED"
    case aiApproved = "AI_APPROVED"
    case humanRejected = "HUMAN_REJECTED"
    case aiRejected = "AI_REJECTED"
    case pending = "PENDING_REVIEW"
    case needsHumanReview = "NEEDS_HUMAN_REVIEW"
}
