//
//  AuthError.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//

enum AuthError: UserFriendlyError {
    case tokenNotFound
    case sessionExpired
    case anonymousUserNotLoggedIn
    
    var title: String {
        return "Oturum Hatası"
    }
    
    var message: String {
        switch self {
        case .tokenNotFound, .sessionExpired:
            return "Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın."
        case .anonymousUserNotLoggedIn:
            return "Anonim kullanıcı girişi yapılamadı."
        }
    }
}
