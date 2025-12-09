//
//  NotificationManager.swift
//  itirafApp
//
//  Created by Emre on 9.12.2025.
//

import UIKit
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            NotificationCenter.default.post(
                name: .didCompleteNotificationRequest,
                object: nil
            )
        }
    }
}
