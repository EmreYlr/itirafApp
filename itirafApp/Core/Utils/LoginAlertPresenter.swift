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
            title: "Giriş Yap",
            message: "Bu işlemi yapmak için giriş yapmalısınız.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Giriş Yap", style: .default, handler: { _ in

            let loginNav = Storyboard.login.instantiateNav(.loginNav)
            loginNav.modalPresentationStyle = .fullScreen
            viewController.present(loginNav, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
}
