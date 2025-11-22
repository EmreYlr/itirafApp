//
//  BusinessError.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//

enum BusinessError: UserFriendlyError {
    case channelIdNotFound
    case invalidConfessionData
    
    var title: String {
        return "İşlem Başarısız"
    }
    
    var message: String {
        switch self {
        case .channelIdNotFound:
            return "Kanal ID'si bulunamadı. Lütfen tekrar deneyin."
        case .invalidConfessionData:
            return "Gönderilen veri bozuk veya eksik."
        }
    }
}
