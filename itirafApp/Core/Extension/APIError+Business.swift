//
//  APIError+Business.swift
//  itirafApp
//
//  Created by Emre on 11.12.2025.
//

extension APIError {
    
    func refinedForBuisness() -> APIError {
        var copy = self
        switch code {
        case 1302:
            copy.customMessage = String(localized: "message.conflict.business")
            copy.customTitle = String(localized: "general.title.error")
        default:
            break
        }
        return copy
    }
}
