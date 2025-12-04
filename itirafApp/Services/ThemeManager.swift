//
//  ThemeManager.swift
//  itirafApp
//
//  Created by Emre on 4.12.2025.
//

import UIKit

enum AppTheme: Int {
    case device = 0
    case light = 1
    case dark = 2
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .device: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var title: String {
        switch self {
        case .device: return "theme.system".localized
        case .light: return "theme.light".localized
        case .dark: return "theme.dark".localized
        }
    }
}

class ThemeManager {
    static let shared = ThemeManager()
    
    private let themeKey = UserDefaults.Keys.selectedTheme.rawValue

    var currentTheme: AppTheme {
        let rawValue = UserDefaults.standard.integer(forKey: themeKey)
        return AppTheme(rawValue: rawValue) ?? .device
    }

    func updateTheme(_ theme: AppTheme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: themeKey)
        applyTheme(theme)
    }

    func applyTheme(_ theme: AppTheme) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.overrideUserInterfaceStyle = theme.userInterfaceStyle
        }, completion: nil)
    }
}
