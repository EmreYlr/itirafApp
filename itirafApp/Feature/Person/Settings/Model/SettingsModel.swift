//
//  SettingsModel.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//
import Foundation

enum SettingsSection: Int, CaseIterable {
    case profile
    case general
    case about
    case support
    
    var title: String {
        switch self {
        case .profile:
            return "settings.section.profile".localized
        case .general:
            return "settings.section.general".localized
        case .about:
            return "settings.section.about".localized
        case .support:
            return "settings.section.support".localized
        }
    }
}

struct SettingItem: Hashable {
    
    enum ItemType: Hashable {
        case editProfile
        case changePassword
        
        case theme
        case notifications
        case language
        
        case privacyPolicy
        case userAgreement
        
        case helpCenter
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
                  iconSystemName: "person.circle",
                  type: .editProfile,
                  isEnabled: enabled)
            
            /*
             .init(title: "settings.item.change_password".localized,
             iconSystemName: "lock",
             type: .changePassword,
             isEnabled: enabled)
             */
        ]
    }
    
    static func getGeneralItems() -> [SettingItem] {
        return [
            .init(title: "settings.item.theme".localized,
                  iconSystemName: "circle.righthalf.filled",
                  type: .theme),
            
                .init(title: "settings.item.notifications".localized,
                      iconSystemName: "bell.badge",
                      type: .notifications),
            
                .init(title: "settings.item.language".localized,
                      iconSystemName: "globe",
                      type: .language)
        ]
    }
    
    static func getAboutItems() -> [SettingItem] {
        return [
            .init(title: "settings.item.privacy_policy".localized,
                  iconSystemName: "hand.raised",
                  type: .privacyPolicy),
            
                .init(title: "settings.item.user_agreement".localized,
                      iconSystemName: "doc.text",
                      type: .userAgreement),
        ]
    }
    
    static func getSupportItems() -> [SettingItem] {
        return [
            .init(title: "settings.item.help_center".localized,
                  iconSystemName: "lifepreserver",
                  type: .helpCenter)
        ]
    }
}
