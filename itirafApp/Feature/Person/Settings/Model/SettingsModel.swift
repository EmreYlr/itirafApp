//
//  SettingsModel.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//
import Foundation

enum SettingsSection: Int, CaseIterable {
    case profile
    case account
    
    var title: String {
        switch self {
        case .profile:
            return "settings.section.profile".localized
        case .account:
            return "settings.section.account".localized
        }
    }
}

struct SettingItem: Hashable {
    
    enum ItemType: Hashable {
        case editProfile
        case changePassword
        case theme
        case privacyPolicy
        case aboutUs
        case notifications
        case language
    }
    
    let title: String
    let iconSystemName: String
    let type: ItemType
    let isEnabled: Bool
    
    private let id = UUID()
    
    init(title: String, iconSystemName: String, type: ItemType, isEnabled: Bool = true) {
        self.title = title
        self.iconSystemName = iconSystemName
        self.type = type
        self.isEnabled = isEnabled
    }
    
    static func getProfileItems(isAnonymous: Bool) -> [SettingItem] {
        let enabled = !isAnonymous
        
        return [
            .init(title: "settings.item.edit_profile".localized,
                  iconSystemName: "person",
                  type: .editProfile,
                  isEnabled: enabled),
            
            .init(title: "settings.item.change_password".localized,
                  iconSystemName: "lock",
                  type: .changePassword,
                  isEnabled: enabled)
        ]
    }
    
    static func getAccountItems() -> [SettingItem] {
        return [
            .init(title: "settings.item.theme".localized, iconSystemName: "circle.righthalf.filled", type: .theme),
            .init(title: "settings.item.notifications".localized, iconSystemName: "bell", type: .notifications),
            .init(title: "settings.item.language".localized, iconSystemName: "globe", type: .language),
            .init(title: "settings.item.privacy_policy".localized, iconSystemName: "shield", type: .privacyPolicy),
            .init(title: "settings.item.about_us".localized, iconSystemName: "info.circle", type: .aboutUs)
        ]
    }
}
