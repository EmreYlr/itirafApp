//
//  NotificationSettingsError.swift
//  itirafApp
//
//  Created by Emre on 24.11.2025.
//


import Foundation

enum NotificationSettingsError: UserFriendlyError {
    case fetchFailed
    case updateFailed
    case cannotOpenSystemSettings
    
    var title: String {
        return "settings.error.title.general".localized
    }
    
    var message: String {
        switch self {
        case .fetchFailed:
            return "settings.error.message.fetch_failed".localized
        case .updateFailed:
            return "settings.error.message.update_failed".localized
        case .cannotOpenSystemSettings:
            return "settings.error.message.cant_open_settings".localized
        }
    }
}