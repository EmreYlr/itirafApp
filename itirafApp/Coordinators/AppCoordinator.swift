//
//  AppCoordinator.swift
//  itirafApp
//
//  Created by Emre on 10.11.2025.
//

import UIKit

final class AppCoordinator {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        setupNotificationObservers()
        
        if !UserManager.shared.getUserIsAnonymous() {
            showHomeController()
        } else {
            Task.detached(priority: .utility) {
                let success = await AuthService.registerAndLoginAnonymousUser()
                
                await MainActor.run {
                    if success {
                        self.showHomeController()
                    } else {
                        // TODO: Hata göster. Şimdilik login'e yönlendirebiliriz.
                        self.showLoginController()
                    }
                }
            }
        }
        
        window.makeKeyAndVisible()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: .userDidLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginRequired), name: .loginRequired, object: nil)
    }
    
    
    @objc private func handleLogout() {
        DispatchQueue.main.async {
            AuthManager.shared.clearTokens()
            UserManager.shared.clear()
            self.showLoginController()
        }
    }
    
    @objc private func showLoginRequired() {
        guard let topVC = UIApplication.topMostViewController() else { return }
        LoginAlertPresenter.showLoginAlert(from: topVC)
    }

    private func showLoginController() {
        let loginNav = Storyboard.login.instantiateNav(.loginNav)
        window.rootViewController = loginNav
    }
    
    private func showHomeController() {
        let tabNav = Storyboard.main.instantiateTabBar(.mainTabBar)
        window.rootViewController = tabNav
    }

    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else {
            return
        }

        print("Universal Link yakaladı: \(incomingURL)")
    }
    
    deinit {
        print("AppCoordinator deinit edildi")
        NotificationCenter.default.removeObserver(self)
    }
}
