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
    var title, message: String
    let likeCount: Int
    let liked: Bool
    let replyCount: Int
    let shareCount: Int
    let createdAt: String
    let channel: ChannelData
    var replies: [Reply]?
    let rejectionReason: String?
    let violations: [Violation]?
    let moderationStatus: ModerationStatus
    let isNsfw: Bool
    
    static func == (lhs: MyConfessionData, rhs: MyConfessionData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.moderationStatus == rhs.moderationStatus &&
        lhs.createdAt == rhs.createdAt &&
        lhs.likeCount == rhs.likeCount &&
        lhs.replyCount == rhs.replyCount
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

enum ConfessionDisplayStatus {
    case approved
    case rejected
    case inReview
    case unknown
}

enum Violation: String, Codable, CaseIterable {
    case none = "NONE"
    case profanity = "PROFANITY"
    case harassment = "HARASSMENT"
    case personalInfo = "PERSONAL_INFO"
    case hateSpeech = "HATE_SPEECH"
    case threat = "THREAT"
    case sexualContent = "SEXUAL_CONTENT"
    case violence = "VIOLENCE"
    case discrimination = "DISCRIMINATION"
    case spam = "SPAM"
    case other = "OTHER"
    
    var description: String {
        switch self {
        case .none:
            return "violation.none".localized
        case .profanity:
            return "violation.profanity".localized
        case .harassment:
            return "violation.harassment".localized
        case .personalInfo:
            return "violation.personal_info".localized
        case .hateSpeech:
            return "violation.hate_speech".localized
        case .threat:
            return "violation.threat".localized
        case .sexualContent:
            return "violation.sexual_content".localized
        case .violence:
            return "violation.violence".localized
        case .discrimination:
            return "violation.discrimination".localized
        case .spam:
            return "violation.spam".localized
        case .other:
            return "violation.other".localized
        }
    }
    
    static var selectableCases: [Violation] {
        return Violation.allCases.filter { $0 != .none }
    }
}
