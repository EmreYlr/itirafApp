//
//  AppDelegate.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit
import UserNotifications
import FirebaseCore
import Clarity

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private let deviceService: DeviceServiceProtocol
    
    override init() {
        self.deviceService = DeviceService()
        super.init()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        ClarityManager.shared.setup()
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        
        #if DEBUG
        print("📱 Device Token: \(token)")
        #endif

        let savedToken = UserDefaults.standard.string(forKey: .deviceToken)
        guard savedToken != token else { return }
        
        UserDefaults.standard.set(token, forKey: .deviceToken)
        
        Task {
            await registerOrUpdateDevice(with: token)
        }
    }
    
    private func registerOrUpdateDevice(with token: String) async {
        do {
            try await deviceService.registerDeviceToken(token, notificationEnabled: true)
        } catch {
            print("❌ Device token kaydedilemedi: \(error.localizedDescription)")
        }
    }
    
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Token alınamadı: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("🔔 Kullanıcı bildirime tıkladı: \(userInfo)")
        
        NotificationCenter.default.post(
            name: .didTapPushNotification,
            object: nil,
            userInfo: userInfo
        )
        
        completionHandler()
    }
    
    // MARK: - UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

