//
//  ErrorPresentable.swift
//  itirafApp
//
//  Created by Emre on 22.11.2025.
//
import Foundation
import UIKit

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
        } else {
            title = "Hata"
            message = error.localizedDescription
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

extension UIViewController: ErrorPresentable {}
