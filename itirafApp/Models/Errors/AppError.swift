//
//  AppError.swift
//  itirafApp
//
//  Created by Emre on 24.11.2025.
//

import Foundation

enum AppError: UserFriendlyError {
    case unknown
    case navigationError
    case invalidInput
    
    var title: String {
        return "Uygulama Hatası"
    }
    
    var message: String {
        switch self {
        case .unknown:
            return "Beklenmedik bir hata oluştu. Lütfen daha sonra tekrar deneyin."
        case .navigationError:
            return "Sayfa geçişi sırasında bir hata oluştu."
        case .invalidInput:
            return "Girdiğiniz bilgiler geçersiz."
        }
    }
}
