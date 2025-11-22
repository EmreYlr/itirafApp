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
        return "Eksik Bilgi"
    }
    
    var message: String {
        switch self {
        case .invalidEmail:
            return "Lütfen geçerli bir e-posta adresi giriniz."
        case .passwordTooShort(let min):
            return "Şifreniz en az \(min) karakter olmalıdır."
        case .emptyField(let fieldName):
            return "\(fieldName) alanı boş bırakılamaz."
        }
    }
}
