//
//  ValidationError.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//

enum ValidationError: UserFriendlyError {
    case invalidEmail
    case passwordTooShort(min: Int)
    case emptyField(fieldName: String)
    
    var title: String {
        return "validation.title.missing_info".localized
    }
    
    var message: String {
        switch self {
        case .invalidEmail:
            return String(localized: "validation.message.invalid_email")
            
        case .passwordTooShort(let min):
            return "validation.message.password_short".localized(min)
            
        case .emptyField(let fieldName):
            return "validation.message.field_empty".localized(fieldName)
        }
    }
}
