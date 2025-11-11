//
//  AppRouter.swift
//  itirafApp
//
//  Created by Emre on 11.11.2025.
//

import UIKit

final class AppRouter {
    private weak var window: UIWindow?
    private var pendingRoute: AppRoute?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func navigate(to route: AppRoute) {
        DispatchQueue.main.async {
            guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
                print("Arayüz hazır değil, rota beklemeye alınıyor: \(route)")
                self.pendingRoute = route
                return
            }
            self.pendingRoute = nil
            
            switch route {
            case .home:
                tabBarController.selectedIndex = 0
                
            case .confessionDetail(let id):
                tabBarController.selectedIndex = 0
                
                guard let nav = tabBarController.selectedViewController as? UINavigationController else { return }
                
                let detailVC: DetailViewController = Storyboard.main.instantiate(.detail)
                detailVC.detailViewModel = DetailViewModel(messageId: id)
                
                let isAppActive = UIApplication.shared.applicationState == .active
                nav.pushViewController(detailVC, animated: isAppActive)
                
            case .passwordReset(let token):
                print("Şifre sıfırlama ekranına yönlendiriliyor: \(token)")
                // TODO: Şifre sıfırlama VC'sini göster
            }
        }
    }
    
    func checkPendingRoute() {
        guard let pendingRoute = self.pendingRoute else {
            return
        }
        
        navigate(to: pendingRoute)
    }
    
    func showLoginRequiredAlert() {
        guard let topVC = UIApplication.topMostViewController() else { return }
        LoginAlertPresenter.showLoginAlert(from: topVC)
    }
}
