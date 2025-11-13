//
//  AppCoordinator.swift
//  itirafApp
//
//  Created by Emre on 10.11.2025.
//

import UIKit

final class AppCoordinator {
    
    private let window: UIWindow
    private let router: AppRouter
    
    init(window: UIWindow) {
        self.window = window
        self.router = AppRouter(window: window)
    }
    
    func start() {
        setupNotificationObservers()
//        setupNavigationBarAppearance()
        
        if !UserManager.shared.getUserIsAnonymous() {
            showHomeController()
        } else {
            Task.detached(priority: .utility) {
                let success = await AuthService.registerAndLoginAnonymousUser()
                
                await MainActor.run {
                    if success {
                        self.showHomeController()
                    } else {
                        self.showLoginController()
                    }
                }
            }
        }
        
        window.makeKeyAndVisible()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginRequired), name: .loginRequired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationNavigation), name: .didTapPushNotification, object: nil)
    }
    
    @objc private func showLoginRequired() {
        router.showLoginRequiredAlert()
    }
    
    @objc func handleNotificationNavigation(_ notification: Notification) {
        router.handleNotificationNavigation(notification)
    }
    
    private func showLoginController() {
        let loginNav = Storyboard.login.instantiateNav(.loginNav)
        window.rootViewController = loginNav
    }
    
    private func showHomeController() {
        let tabNav = Storyboard.main.instantiateTabBar(.mainTabBar)
        window.rootViewController = tabNav
        
        router.checkPendingRoute()
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().tintColor = .label

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else {
            return
        }
        
        print("Universal Link yakaladı: \(incomingURL)")
        handleDeeplink(url: incomingURL)
    }
    
    func handleDeeplink(url: URL) {
        guard let route = DeeplinkParser.parse(url: url) else {
            print("Anlaşılamayan veya hatalı link: \(url)")
            router.navigate(to: .home)
            return
        }
        
        router.navigate(to: route)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
