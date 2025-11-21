//
//  NotificationParser.swift
//  itirafApp
//
//  Created by Emre on 11.11.2025.
//

import Foundation

struct NotificationParser {
    
    static func parse(item: NotificationItem) -> AppRoute? {
        let eventType = item.eventType
        let data = item.data
        
        switch eventType {
        case .dmReceived:
            guard let roomId = data.roomId,
                  let senderName = data.senderName, let senderId = data.senderId else { return nil }
            return .directMessage(roomId: roomId, senderName: senderName, senderId: senderId)
            
        case .confessionReplied:
            guard let messageId = data.messageId else { return nil }
            
            guard let messageIdInt = Int(messageId) else {
                return nil
            }
            guard let commentId = data.commentId,
                  let commentIdInt = Int(commentId) else {
                return nil
            }
            
            return .confessionDetail(id: messageIdInt, commentId: commentIdInt)
            
        case .confessionLiked:
            guard let messageId = data.messageId else { return nil }
            guard let messageIdInt = Int(messageId) else {
                return nil
            }
            
            return .confessionDetail(id: messageIdInt)
            
        case .dmRequestReceived:
            guard let requestId = data.requestId else { return nil }
            
            return .requestDetail(requestId: requestId)
            
        case .dmRequestResponded:
            if let status = data.status, status == .accepted,
               let roomId = data.roomId,
               let senderName = data.senderName, let senderId = data.senderId {
                return .directMessage(roomId: roomId, senderName: senderName, senderId: senderId)
            } else {
                guard let requestId = data.requestId else { return nil }
                return .requestResponse(requestId: requestId)
            }
            
        case .confessionModerated:
            return .myConfessions
            
        case .confessionPublished:
            return .home
            
        case .adminReviewRequired:
            guard let messageId = data.messageId else { return nil }
            guard let messageIdInt = Int(messageId) else {
                return nil
            }
            
            return .moderation(messageId: messageIdInt)
            
        case .unknown:
            return nil
        }
    }
    
    static func parse(userInfo: [AnyHashable: Any]) -> AppRoute? {
        
        guard let payloadDict = userInfo["payload"] as? [String: Any] else {
            print("NotificationParser: 'payload' bulunamadı.")
            return nil
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payloadDict, options: []),
              let payloadWrapper = try? JSONDecoder().decode(NotificationPayloadWrapper.self, from: jsonData) else {
            print("NotificationParser: Decode hatası.")
            return nil
        }
        
        let eventType = payloadWrapper.eventType
        let data = payloadWrapper.data
        
        switch eventType {
            //TODO: -Gittiği Ekranlardaki verilere göre düzenleme yap(cell parlat vs)
        case .dmReceived:
            guard let roomId = data.roomId,
                  let senderName = data.senderName, let senderId = data.senderId else { return nil }
            return .directMessage(roomId: roomId, senderName: senderName, senderId: senderId)
            
        case .confessionReplied:
            guard let messageId = data.messageId else { return nil }
            
            guard let messageIdInt = Int(messageId) else {
                return nil
            }
            guard let commentId = data.commentId,
                  let commentIdInt = Int(commentId) else {
                return nil
            }
            
            return .confessionDetail(id: messageIdInt, commentId: commentIdInt)
            
        case .confessionLiked:
            guard let messageId = data.messageId else { return nil }
            guard let messageIdInt = Int(messageId) else {
                return nil
            }
            
            return .confessionDetail(id: messageIdInt)
            
        case .dmRequestReceived:
            guard let requestId = data.requestId else { return nil }
            
            return .requestDetail(requestId: requestId)
            
        case .dmRequestResponded:
            if let status = data.status, status == .accepted,
               let roomId = data.roomId,
               let senderName = data.senderName, let senderId = data.senderId {
                return .directMessage(roomId: roomId, senderName: senderName, senderId: senderId)
            } else {
                guard let requestId = data.requestId else { return nil }
                return .requestResponse(requestId: requestId)
            }
            
        case .confessionModerated:
            return .myConfessions
            
        case .confessionPublished:
            return .home
            
        case .adminReviewRequired:
            guard let messageId = data.messageId else { return nil }
            guard let messageIdInt = Int(messageId) else {
                return nil
            }
            
            return .moderation(messageId: messageIdInt)
            
        case .unknown:
            return nil
        }
    }
}
