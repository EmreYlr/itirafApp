//
//  AppError.swift
//  itirafApp
//
//  Created by Emre on 21.10.2025.
//

import Foundation

enum AppError: Error, LocalizedError {
    case channelIdNotFound
    case anonymousUserNotLoggedIn
    
    var errorDescription: String? {
        switch self {
        case .channelIdNotFound:
            return "Kanal ID'si bulunamadı. Lütfen tekrar deneyin."
        case .anonymousUserNotLoggedIn:
            return "Anonim kullanıcı olarak giriş yapılamadı. Lütfen uygulamayı kapatıp tekrar açın."
        }
    }
}
