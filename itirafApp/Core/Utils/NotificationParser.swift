//
//  NotificationParser.swift
//  itirafApp
//
//  Created by Emre on 11.11.2025.
//

import Foundation

enum NotificationType: String, Codable {
    case dmMessage = "DM_MESSAGE"
    case dmRequest = "DM_REQUEST"
    case dmResponse = "DM_REQUEST_RESPONSE"
    case reply = "REPLY"
    case moderation = "MODERATION"
    case like = "LIKE"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try NotificationType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

struct NotificationParser {
    static func parse(userInfo: [AnyHashable: Any]) -> AppRoute? {
        guard let typeString = userInfo["type"] as? String,
              let type = NotificationType(rawValue: typeString) else {
            print("❌ NotificationParser: Tanımlanamayan bildirim tipi. userInfo: \(userInfo)")
            return nil
        }
        
        switch type {
        case .dmMessage:
            guard let roomId = userInfo["roomId"] as? String else {
                print("❌ NotificationParser: DM tipi için 'roomId' bulunamadı.")
                return nil
            }
            let username = userInfo["username"] as? String ?? "Chat"
            return .directMessage(roomId: roomId, username: username)
            
        case .reply:
            guard let messageIdString = userInfo["messageId"] as? String else {
                print("❌ NotificationParser: Reply tipi için 'messageId' (String olarak) bulunamadı.")
                return nil
            }

            guard let messageIdInt = Int(messageIdString) else {
                return nil
            }
            
            return .confessionDetail(id: messageIdInt)
            
        case .moderation:
            return .myConfessions
            //TODO: -Buralar dolacak ekranlara gidecek
        case .like:
            print("Like")
            return nil
        case .dmRequest:
            print("Dm request")
            return nil
        case .dmResponse:
            print("Dm Response")
            return nil
        case .unknown:
            print("❌ NotificationParser: Bilinmeyen bildirim tipi.")
            return nil
        }
        
    }
}
