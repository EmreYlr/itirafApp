//
//  RequestSentElement.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//

import Foundation

struct RequestSentModel: Codable, Hashable {
    let requestID, requesterUsername, initialMessage, confessionTitle: String
    let confessionMessage: String
    let channelMessageID: Int
    let createdAt: String
    let status: RequestStatus

    enum CodingKeys: String, CodingKey {
        case requestID = "requestId"
        case requesterUsername, initialMessage, confessionTitle, confessionMessage
        case channelMessageID = "channelMessageId"
        case createdAt, status
    }
    static func == (lhs: RequestSentModel, rhs: RequestSentModel) -> Bool {
        return lhs.requestID == rhs.requestID &&
        lhs.status == rhs.status
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(requestID)
    }
}

enum RequestStatus: String, Codable {
    case pending = "PENDING"
    case rejected = "REJECTED"
    
    var description: String {
        switch self {
        case .pending:
            return "Beklemede"
        case .rejected:
            return "Reddedildi"
        }
    }
}
