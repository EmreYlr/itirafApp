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
        return "auth.error.title.session".localized
    }
    
    var message: String {
        switch self {
        case .tokenNotFound, .sessionExpired:
            return "auth.error.message.session_not_found".localized
            
        case .anonymousUserNotLoggedIn:
            return "auth.error.message.anonymous_login_failed".localized
        }
    }
}
