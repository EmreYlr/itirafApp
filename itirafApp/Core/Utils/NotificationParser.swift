//
//  NotificationParser.swift
//  itirafApp
//
//  Created by Emre on 11.11.2025.
//

import Foundation

enum NotificationType: String {
    case dm
    case reply
    case moderation
}

struct NotificationParser {
    static func parse(userInfo: [AnyHashable: Any]) -> AppRoute? {
        guard let typeString = userInfo["type"] as? String,
              let type = NotificationType(rawValue: typeString) else {
            print("❌ NotificationParser: Tanımlanamayan bildirim tipi. userInfo: \(userInfo)")
            return nil
        }
        
        switch type {
        case .dm:
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
            
        }
        
    }
}
