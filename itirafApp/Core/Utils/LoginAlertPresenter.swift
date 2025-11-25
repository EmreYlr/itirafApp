//
//  LoginAlertPresenter.swift
//  itirafApp
//
//  Created by Emre on 25.09.2025.
//

import UIKit

final class LoginAlertPresenter {
    static func showLoginAlert(from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "login.alert.title".localized,
            message: "login.alert.message".localized,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "login.button.login".localized, style: .default, handler: { _ in

            let loginNav = Storyboard.login.instantiateNav(.loginNav)
            loginNav.modalPresentationStyle = .fullScreen
            viewController.present(loginNav, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "general.button.cancel".localized, style: .cancel))
        
        viewController.present(alert, animated: true)
    }
}
