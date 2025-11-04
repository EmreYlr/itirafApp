//
//  SceneDelegate.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Logout notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: .userDidLogout, object: nil)
        
        // LoginRequired notification
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginRequired), name: .loginRequired, object: nil)
        
        if UserManager.shared.hasRole(.admin) {
            window.rootViewController = createHomeController()
            window.makeKeyAndVisible()
            return
        }
        
        if !UserManager.shared.getUserIsAnonymous() {
            window.rootViewController = createHomeController()
            window.makeKeyAndVisible()
            return
        }
        
        Task.detached(priority: .utility) {
            let success = await AuthService.registerAndLoginAnonymousUser()
            if success {
                await MainActor.run {
                    self.window?.rootViewController = self.createHomeController()
                }
            } else {
                // TODO: hata göster
            }
        }
        window.makeKeyAndVisible()
    }


    @objc private func handleLogout() {
        AuthManager.shared.clearTokens()
        UserManager.shared.clear()
        DispatchQueue.main.async {
            self.window?.rootViewController = self.createLoginController()
        }
    }

    @objc private func showLoginRequired() {
        guard let topVC = UIApplication.topMostViewController() else { return }
        LoginAlertPresenter.showLoginAlert(from: topVC)
    }
    
    private func createLoginController() -> UIViewController {
        let loginNav = Storyboard.login.instantiateNav(.loginNav)
        return loginNav
    }


    private func createHomeController() -> UIViewController {
        let tabNav = Storyboard.main.instantiateTabBar(.mainTabBar)
        return tabNav
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

