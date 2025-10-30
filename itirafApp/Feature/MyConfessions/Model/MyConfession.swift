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
    let createdAt: String
    let channel: ChannelData
    var replies: [Reply]?
    let rejectionReason: String?
    let violations: [Violation]?
    let moderationStatus: ModerationStatus
    
    static func == (lhs: MyConfessionData, rhs: MyConfessionData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.message == rhs.message &&
        lhs.moderationStatus == rhs.moderationStatus
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

enum Violation: String, Codable {
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
    
    var turkishDescription: String {
        switch self {
        case .none:
            return "İhlal Yok"
        case .profanity:
            return "Küfür"
        case .harassment:
            return "Taciz"
        case .personalInfo:
            return "Kişisel Bilgi Paylaşımı"
        case .hateSpeech:
            return "Nefret Söylemi"
        case .threat:
            return "Tehdit"
        case .sexualContent:
            return "Cinsel İçerik"
        case .violence:
            return "Şiddet"
        case .discrimination:
            return "Ayrımcılık"
        case .spam:
            return "Spam"
        case .other:
            return "Diğer"
        }
    }
}
