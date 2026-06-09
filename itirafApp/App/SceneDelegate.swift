//
//  SceneDelegate.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit
import GoogleSignIn

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)

        self.window = window
        
        window.overrideUserInterfaceStyle = ThemeManager.shared.currentTheme.userInterfaceStyle
                
        self.appCoordinator = AppCoordinator(window: window)
        
        self.appCoordinator?.start()
        
        if let userActivity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }) {
            appCoordinator?.handleUserActivity(userActivity)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        let googleHandled = GIDSignIn.sharedInstance.handle(url)
        
        if googleHandled {
            return
        }

        appCoordinator?.handleDeeplink(url: url)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        appCoordinator?.handleUserActivity(userActivity)
    }
}

