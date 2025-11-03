//
//  UIApplication+Extension.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//
import UIKit

extension UIApplication {
    static func topMostViewController(base: UIViewController? = UIApplication.shared
        .connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.windows.first { $0.isKeyWindow }?.rootViewController }
        .first) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        } else if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
