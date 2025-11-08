//
//  AppDelegate.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private let deviceService: DeviceServiceProtocol
    
    override init() {
        let networkService = NetworkManager.shared
        self.deviceService = DeviceService(networkService: networkService)
        super.init()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Bildirim izni reddedildi.")
            }
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        let oldToken = UserDefaults.standard.string(forKey: "deviceToken")
        print("Device Token: \(token)")
        if oldToken != token {
            UserDefaults.standard.set(token, forKey: "deviceToken")
            Task {
                do {
                    try await self.deviceService.registerDeviceToken(token)
                } catch {
                    print("Device token kaydedilemedi: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Token alınamadı: \(error.localizedDescription)")
    }
    
    // MARK: - UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

