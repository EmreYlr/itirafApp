//
//  RequestMessageModel.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//
import Foundation

struct RequestMessageModel: Codable, Hashable {
    let requestID, roomID, requesterUsername, requesterUserID: String
    let requesterSocialLinks: [Link]?
    let initialMessage, confessionTitle: String
    let channelMessageID: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case requestID = "requestId"
        case roomID = "roomId"
        case requesterUsername
        case requesterUserID = "requesterUserId"
        case requesterSocialLinks, initialMessage, confessionTitle
        case channelMessageID = "channelMessageId"
        case createdAt
    }
    static func == (lhs: RequestMessageModel, rhs: RequestMessageModel) -> Bool {
        return lhs.requestID == rhs.requestID &&
        lhs.roomID == rhs.roomID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(roomID)
    }
}

struct RequestMessageResponse: Codable {
    let roomId: String?
    let message: String
}
