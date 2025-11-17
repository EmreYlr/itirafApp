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
            return "PROFİL"
        case .account:
            return "HESAP"
        }
    }
}

struct SettingItem: Hashable {
    
    enum ItemType: Hashable {
        case editProfile
        case changePassword
        case privacyPolicy
        case aboutUs
        case notifications
    }
    
    let title: String
    let iconSystemName: String
    let type: ItemType
    
    private let id = UUID()
    
    static func getProfileItems() -> [SettingItem] {
        return [
            .init(title: "Profili Düzenle", iconSystemName: "person", type: .editProfile),
            .init(title: "Şifreyi Değiştir", iconSystemName: "lock", type: .changePassword)
        ]
    }
    
    static func getAccountItems() -> [SettingItem] {
        return [
            .init(title: "Bildirimler", iconSystemName: "bell", type: .notifications),
            .init(title: "Gizlilik Politikası", iconSystemName: "shield", type: .privacyPolicy),
            .init(title: "Hakkımızda", iconSystemName: "info.circle", type: .aboutUs)
        ]
    }
}
