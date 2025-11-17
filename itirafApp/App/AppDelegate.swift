//
//  AppDelegate.swift
//  itirafApp
//
//  Created by Emre on 12.09.2025.
//

import UIKit
import UserNotifications
import FirebaseCore

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
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Bildirim izni reddedildi.")
            }
            NotificationCenter.default.post(
                name: .didCompleteNotificationRequest,
                object: nil
            )
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
//        print("📱 Device Token: \(token)")
        
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
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

