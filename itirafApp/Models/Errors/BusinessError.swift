//
//  BusinessError.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//

enum BusinessError: UserFriendlyError {
    case channelIdNotFound
    case invalidConfessionData
    case requestSentIdNotFound
    
    var title: String {
        return "business.error.title.failed".localized
    }
    
    var message: String {
        switch self {
        case .channelIdNotFound:
            return "business.error.message.channel_id_not_found".localized
        case .invalidConfessionData:
            return "business.error.message.invalid_data".localized
        case .requestSentIdNotFound:
            return "business.error.message.request_sent_id_not_found".localized
        }
        
    }
}
