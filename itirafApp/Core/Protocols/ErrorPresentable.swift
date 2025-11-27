//
//  ErrorPresentable.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//
import Foundation
import UIKit
import Alamofire

protocol ErrorPresentable {
    func handleError(_ error: Error)
}

extension ErrorPresentable where Self: UIViewController {
    
    func handleError(_ error: Error) {
        let title: String
        let message: String

        if let userFriendlyError = error as? UserFriendlyError {
            title = userFriendlyError.title
            message = userFriendlyError.message
        }

        else if let afError = error as? AFError {
            (title, message) = parseNetworkError(afError)
        }

        else {
            title = "error.unknown".localized
            message = error.localizedDescription
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "general.button.ok".localized, style: .default))
        present(alert, animated: true)
    }
    
    private func parseNetworkError(_ error: AFError) -> (String, String) {
        switch error {
        case .sessionTaskFailed(let underlyingError):
            if let urlError = underlyingError as? URLError {
                return parseURLError(urlError)
            }
            return ("error.connection_failed".localized, "error.connection.server_unreachable".localized)
            
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                switch code {
                case 401:
                    return ("error.session_expired".localized, "error.session_expired.message".localized)
                case 500...599:
                    return ("error.server".localized, "error.server.maintenance".localized)
                default:
                    return ("error.title.unexpected".localized, String(format: "error.unexpected.message_format".localized, "\(code)"))
                }
            default:
                return ("error.unknown".localized, "error.invalid_response.message".localized)
            }
            
        case .explicitlyCancelled:
            return ("error.cancelled.title".localized, "error.cancelled.message".localized)
            
        default:
            return ("error.connection_failed".localized, "error.message.check_internet".localized)
        }
    }
    
    private func parseURLError(_ error: URLError) -> (String, String) {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return ("error.no_internet.title".localized, "error.no_internet.message".localized)
        case .timedOut:
            return ("error.timeout".localized, "error.timeout.message".localized)
        default:
            return ("error.unknown".localized, error.localizedDescription)
        }
    }
}

extension UIViewController: ErrorPresentable {}
