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
        return "error.title.app_error".localized
    }
    
    var message: String {
        switch self {
        case .unknown:
            return "error.message.unexpected".localized
        case .navigationError:
            return "error.message.navigation_error".localized
        case .invalidInput:
            return "error.message.invalid_input".localized
        }
    }
}
