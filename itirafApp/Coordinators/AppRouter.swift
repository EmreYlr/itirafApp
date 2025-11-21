//
//  AppRouter.swift
//  itirafApp
//
//  Created by Emre on 11.11.2025.
//

import UIKit

final class AppRouter {
    // MARK: - Properties
    private weak var window: UIWindow?
    private var pendingRoute: AppRoute?
    
    private var shouldAnimate: Bool {
        UIApplication.shared.applicationState == .active
    }

    init(window: UIWindow?) {
        self.window = window
    }
    
    func navigate(to route: AppRoute, preferCurrentTab: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
                print("⚠️ Arayüz hazır değil, rota beklemeye alınıyor: \(route)")
                self.pendingRoute = route
                return
            }
            
            self.pendingRoute = nil
            self.handleRoute(route, on: tabBarController, preferCurrentTab: preferCurrentTab)
        }
    }
    
    func checkPendingRoute() {
        guard let pendingRoute = self.pendingRoute else { return }
        navigate(to: pendingRoute)
    }
    
    func showLoginRequiredAlert() {
        guard let topVC = UIApplication.topMostViewController() else { return }
        LoginAlertPresenter.showLoginAlert(from: topVC)
    }
    
    func handleNotificationNavigation(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let route = NotificationParser.parse(userInfo: userInfo) else {
            print("⚠️ Bilinmeyen bildirim türü, ana sayfaya yönlendiriliyor.")
            self.navigate(to: .home)
            return
        }
        
        self.navigate(to: route)
    }
    
    private func handleRoute(_ route: AppRoute, on tabBar: UITabBarController, preferCurrentTab: Bool) {
        switch route {
        case .home:
            navigateToHome(on: tabBar, preferCurrentTab: preferCurrentTab)
            
        case .confessionDetail(let id, let commentId):
            navigateToConfessionDetail(id: id, commentId: commentId, on: tabBar, preferCurrentTab: preferCurrentTab)
            
        case .passwordReset(let token):
            navigateToPasswordReset(token: token)
            
        case .directMessage(let roomId, let senderName, _):
            navigateToDirectMessage(roomId: roomId, senderName: senderName, on: tabBar, preferCurrentTab: preferCurrentTab)
            
        case .myConfessions:
            navigateToMyConfessions(on: tabBar, preferCurrentTab: preferCurrentTab)
            
        case .requestDetail(let requestId):
            navigateToRequestDetail(requestId: requestId, on: tabBar)
            
        case .requestResponse(let requestId):
            navigateToRequestResponse(requestId: requestId, on: tabBar)
        case .moderation(let messageId):
            navigateToModeration(id: messageId, on: tabBar, preferCurrentTab: preferCurrentTab)
        }
    }
}

private extension AppRouter {
    func navigateToHome(on tabBar: UITabBarController, preferCurrentTab: Bool) {
        if !preferCurrentTab {
            tabBar.selectedIndex = TabBarIndex.home.rawValue
        }
    }
    
    func navigateToConfessionDetail(id: Int, commentId: Int?, on tabBar: UITabBarController, preferCurrentTab: Bool) {
        if !preferCurrentTab {
            tabBar.selectedIndex = TabBarIndex.home.rawValue
        }
        
        let detailVC: DetailViewController = Storyboard.main.instantiate(.detail)
        detailVC.detailViewModel = DetailViewModel(messageId: id, commentId: commentId)
        
        pushToSelectedNav(on: tabBar, viewController: detailVC)
    }
    
    func navigateToPasswordReset(token: String) {
        // TODO: Şifre sıfırlama VC'sini göster
        print("🔐 Şifre sıfırlama ekranına yönlendiriliyor: \(token)")
    }
    
    func navigateToDirectMessage(roomId: String, senderName: String, on tabBar: UITabBarController, preferCurrentTab: Bool) {
        if !preferCurrentTab {
            tabBar.selectedIndex = TabBarIndex.home.rawValue
        }
        
        let chatVC: ChatViewController = Storyboard.chat.instantiate(.chat)
        chatVC.viewModel.directMessage = DirectMessage(
            roomID: roomId,
            username: senderName,
            lastMessage: "",
            lastMessageDate: "",
            isLastMessageMine: false,
            status: "APPROVED",
            unreadMessageCount: 0
        )
        chatVC.mode = .directMessage
        
        pushToSelectedNav(on: tabBar, viewController: chatVC)
    }
    
    func navigateToMyConfessions(on tabBar: UITabBarController, preferCurrentTab: Bool) {
        let targetIndex = TabBarIndex.myConfession.rawValue
        if !preferCurrentTab {
            tabBar.selectedIndex = targetIndex
        }
        
        if let nav = tabBar.viewControllers?[targetIndex] as? UINavigationController {
            nav.popToRootViewController(animated: true)
        }
    }
    
    func navigateToRequestDetail(requestId: String, on tabBar: UITabBarController) {
        let containerVC = MessagingContainerViewController()
        containerVC.initialIndex = 1
        containerVC.requestsVC.viewModel = RequestMessageViewModel(requestId: requestId)
        pushToSelectedNav(on: tabBar, viewController: containerVC)
    }
    
    func navigateToRequestResponse(requestId: String, on tabBar: UITabBarController) {
        let responseVC: RequestSentViewController = Storyboard.requestSent.instantiate(.requestSent)
        responseVC.viewModel = RequestSentViewModel(requestId: requestId)
        pushToSelectedNav(on: tabBar, viewController: responseVC)
    }
    
    func navigateToModeration(id: Int, on tabBar: UITabBarController, preferCurrentTab: Bool) {
        if !preferCurrentTab {
            tabBar.selectedIndex = TabBarIndex.myConfession.rawValue
        }
        
        let moderationVC: ModerationViewController = Storyboard.moderation.instantiate(.moderation)
        moderationVC.viewModel = ModerationViewModel(messageId: id)
        pushToSelectedNav(on: tabBar, viewController: moderationVC)
    }
    
    func pushToSelectedNav(on tabBar: UITabBarController, viewController: UIViewController) {
        guard let nav = tabBar.selectedViewController as? UINavigationController else {
            print("⚠️ Hata: Seçili tab bir UINavigationController değil.")
            return
        }
        nav.pushViewController(viewController, animated: shouldAnimate)
    }
}
