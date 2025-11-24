//
//  APIError+Auth.swift
//  itirafApp
//
//  Created by Emre on 24.11.2025.
//

import Foundation

extension APIError {
    
    func refinedForRegister() -> APIError {
        var copy = self
        switch code {
        case 1302: 
            copy.customMessage = String(localized: "message.register_conflict")
            copy.customTitle = String(localized: "error.register_failed")
        default: break
        }
        return copy
    }

    func refinedForLogin() -> APIError {
        var copy = self
        switch code {
        case 1404: copy.customMessage = String(localized: "message.login_credentials_error")
        default: break
        }
        return copy
    }
}
