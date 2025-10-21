//
//  AppError.swift
//  itirafApp
//
//  Created by Emre on 21.10.2025.
//

import Foundation

enum AppError: Error, LocalizedError {
    case channelIdNotFound
    
    var errorDescription: String? {
        switch self {
        case .channelIdNotFound:
            return "Kanal ID'si bulunamadı. Lütfen tekrar deneyin."
        }
    }
}
