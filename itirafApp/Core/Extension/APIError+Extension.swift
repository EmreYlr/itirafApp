//
//  APIError+Extension.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//

extension APIError: UserFriendlyError {
    var title: String {
        if let custom = customTitle {
            return custom
        }
        switch code {
        // General
        case 1000...1001, 4000...4001: return String(localized: "error.server")
        case 1002, 4002: return String(localized: "error.bad_request")
        case 1003, 4003: return String(localized: "error.too_many_requests")
            
        // Validation
        case 1100...1199, 4100...4199: return String(localized: "error.validation")
            
        // Database
        case 1200, 4200: return String(localized: "error.server")
        case 1201, 4201: return String(localized: "error.record_exists")
            
        // Resource
        case 1300, 4300: return String(localized: "error.not_found")
        case 1301, 4301: return String(localized: "error.already_exists")
        case 1302, 4302: return String(localized: "error.conflict")
            
        // Authentication
        case 1400, 4400: return String(localized: "error.unauthorized")
        case 1401, 4401: return String(localized: "error.session_invalid")
        case 1402, 4402: return String(localized: "error.session_expired")
        case 1403, 4403: return String(localized: "error.access_denied")
        case 1404, 4404: return String(localized: "error.auth_failed")
        case 1405, 4405: return String(localized: "error.account_not_verified")
        case 1406...1408, 4406...4408: return String(localized: "error.login_failed")
            
        // External Service
        case 1500, 4500: return String(localized: "error.server")
        case 1501, 4501: return String(localized: "error.timeout")
        case 1503...1504, 4503...4504: return String(localized: "error.server")
            
        // Business Logic
        case 1600, 4600: return String(localized: "error.process_failed")
        case 1601...1602, 4601...4602: return String(localized: "error.server")
            
        // WebSocket
        case 1700...1999, 4700...4999: return String(localized: "error.connection_failed")
            
        default: return String(localized: "error.unknown")
        }
    }
    
    var message: String {
        if let custom = customMessage {
            return custom
        }
        
        switch code {
        // INTERNAL ERRORS - Hide details from user
        case 1000, 1001, 1200, 1500, 1503, 1504, 1601, 1602,
             4000, 4001, 4200, 4500, 4503, 4504, 4601, 4602:
            return String(localized: "message.server_error")
            
        // CLIENT DISPLAYABLE ERRORS
        // General
        case 1002, 4002: return String(localized: "message.bad_request")
        case 1003, 4003: return String(localized: "message.too_many_requests")
            
        // Validation
        case 1100, 4100: return String(localized: "message.validation_error")
        case 1101, 4101: return String(localized: "message.invalid_input")
        case 1102, 4102: return String(localized: "message.missing_fields")
        case 1100...1199, 4100...4199: return String(localized: "message.check_input")
            
        // Database
        case 1201, 4201: return String(localized: "message.record_exists")
            
        // Resource
        case 1300, 4300: return String(localized: "message.not_found")
        case 1301, 4301: return String(localized: "message.already_exists")
        case 1302, 4302: return String(localized: "message.conflict")
            
        // Authentication
        case 1400, 4400: return String(localized: "message.unauthorized")
        case 1401, 4401: return String(localized: "message.session_invalid")
        case 1402, 4402: return String(localized: "message.session_expired")
        case 1403, 4403: return String(localized: "message.access_denied")
        case 1404, 4404: return String(localized: "message.auth_failed")
        case 1405, 4405: return String(localized: "message.account_not_verified")
        case 1406, 4406: return String(localized: "message.invalid_provider")
        case 1407, 4407: return String(localized: "message.invalid_token")
        case 1408, 4408: return String(localized: "message.social_email_unverified")
        case 1409, 4409: return String(localized: "message.deleted_account_error")
            
        // External Service
        case 1501, 4501: return String(localized: "message.timeout")
            
        // Business Logic
        case 1600, 4600: return String(localized: "message.process_failed")
            
        // WebSocket
        case 1700...1999, 4700...4999:
            return String(localized: "message.connection_failed")
            
        default:
            return String(localized: "message.unexpected_error")
        }
    }
}

