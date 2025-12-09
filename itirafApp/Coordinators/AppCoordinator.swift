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
        configureCrashlyticsIdentity()
        setupNotificationObservers()
        //setupNavigationBarAppearance()
        
        if shouldShowOnboarding() {
            showOnboarding()
        } else if !hasAcceptedTerms() {
            showTerms()
        } else {
            startMainFlow()
        }
        
        window.makeKeyAndVisible()
    }
    
    private func shouldShowOnboarding() -> Bool {
        return !UserDefaults.standard.bool(forKey: .hasSeenOnboarding)
    }
    
    private func hasAcceptedTerms() -> Bool {
        return UserDefaults.standard.bool(forKey: .hasAcceptedTerms)
    }
    
    private func showOnboarding() {
        let onboardingVC: OnboardingViewController = Storyboard.onboarding.instantiate(.onboarding)
        onboardingVC.viewModel = OnboardingViewModel()
        onboardingVC.didFinishOnboarding = { [weak self] in
            guard let self = self else { return }
            UserDefaults.standard.set(true, forKey: .hasSeenOnboarding)
            self.showTerms()
        }
        window.rootViewController = onboardingVC
    }
    
    private func showTerms() {
        let termsVC: TermsViewController = Storyboard.terms.instantiate(.terms)
        
        termsVC.didFinishTerms = { [weak self] in
            guard let self = self else { return }
            self.startMainFlow()
        }
        
        if window.rootViewController != nil {
            termsVC.modalTransitionStyle = .crossDissolve
            termsVC.modalPresentationStyle = .fullScreen
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.window.rootViewController = termsVC
            }, completion: nil)
            
        } else {
            window.rootViewController = termsVC
        }
    }
    
    private func startMainFlow() {
        NotificationManager.shared.requestNotificationPermission()
        
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
    }
    
    private func configureCrashlyticsIdentity() {
        if let cachedUserID = UserManager.shared.getUserID() {
            CrashlyticsManager.shared.setUserID(cachedUserID)
            CrashlyticsManager.shared.isUserAnonymous(UserManager.shared.getUserIsAnonymous())
        } else {
            CrashlyticsManager.shared.isUserAnonymous(true)
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginRequired), name: .loginRequired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationNavigation), name: .didTapPushNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInternalNavigation(_:)), name: .shouldNavigateToRoute, object: nil)
    }
    
    @objc private func showLoginRequired() {
        router.showLoginRequiredAlert()
    }
    
    @objc func handleNotificationNavigation(_ notification: Notification) {
        router.handleNotificationNavigation(notification)
    }
    
    @objc private func handleInternalNavigation(_ notification: Notification) {
        guard let route = notification.object as? AppRoute else { return }
        router.navigate(to: route, preferCurrentTab: true)
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
