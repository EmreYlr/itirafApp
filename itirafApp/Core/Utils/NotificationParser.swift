//
//  NotificationParser.swift
//  itirafApp
//
//  Created by Emre on 11.11.2025.
//

import Foundation

struct NotificationParser {
    
    static func parse(userInfo: [AnyHashable: Any]) -> AppRoute? {
        
        guard let payloadDict = userInfo["payload"] as? [String: Any] else {
            print("❌ NotificationParser: 'payload' bulunamadı.")
            return nil
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payloadDict, options: []),
              let payloadWrapper = try? JSONDecoder().decode(NotificationPayloadWrapper.self, from: jsonData) else {
            print("❌ NotificationParser: Decode hatası.")
            return nil
        }
        
        let eventType = payloadWrapper.eventType
        let data = payloadWrapper.data
        //TODO: -Bu kısmı düzenle
        switch eventType {
            
        case .dmReceived:
            guard let roomId = data.roomId,
                  let senderName = data.senderName else { return nil }
            return .directMessage(roomId: roomId, username: senderName)
            
        case .confessionReplied:
            guard let messageId = data.messageId else { return nil }
            // commentId eklenecek
            guard let messageIdInt = Int(messageId) else {
                return nil
            }
            return .confessionDetail(id: messageIdInt)
            
        case .confessionLiked:
            guard let messageId = data.messageId else { return nil }
            guard let messageIdInt = Int(messageId) else {
                return nil
            }
            return .confessionDetail(id: messageIdInt)
            
        case .dmRequestReceived:
            return nil
//            guard let requestId = data.requestId else { return nil }
//            return .requestDetail(requestId: requestId)
            
        case .dmRequestResponded:
            return nil
//            if let status = data.status, status == "ACCEPTED",
//               let roomId = data.roomId,
//               let senderName = data.senderName {
//                return .directMessage(roomId: roomId, username: senderName)
//            }
//            return nil
            
        case .confessionModerated:
            return .myConfessions
            
        case .adminReviewRequired, .confessionPublished:
             return .home
            
        case .unknown:
            return nil
        }
    }
}
