//
//  NotificationSettingsViewModel.swift
//  itirafApp
//
//  Created by Emre on 17.11.2025.
//
import UIKit

protocol NotificationSettingsViewModelProtocol {
    var delegate: NotificationSettingsViewModelDelegate? { get set }
    func checkCurrentNotificationState()
    func handleSwitchTap()
    func getNotificationPreferences() async
    func updateItemState(channel: NotificationPreferencesChannel, isOn: Bool)
    func saveChangesIfAny() async
}

protocol NotificationSettingsViewModelDelegate: AnyObject {
    func updateSwitchState(isOn: Bool)
    func reloadPreferences(items: [NotificationPreferencesItem])
    func didFailWithError(_ error: Error)
}

final class NotificationSettingsViewModel {
    var delegate: NotificationSettingsViewModelDelegate?
    let service: NotificationSettingsServiceProtocol
    
    private var originalItems: [NotificationPreferencesItem] = []
    private var currentItems: [NotificationPreferencesItem] = []
    private var originalPushState: Bool = false
    private var currentSystemPushState: Bool = false
    
    init(service: NotificationSettingsServiceProtocol = NotificationSettingsService()) {
        self.service = service
    }
    
    func getNotificationPreferences() async {
        do {
            let preferences = try await service.getNotificationPreferences()
            
            self.originalItems = preferences.items
            self.currentItems = preferences.items
            self.originalPushState = preferences.pushEnabled
            
            self.delegate?.reloadPreferences(items: preferences.items)
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func saveChangesIfAny() async {
        let changedItems = currentItems.filter { current in
            guard let original = originalItems.first(where: { $0.channel == current.channel }) else { return false }
            return original.enabled != current.enabled
        }
        
        let isPushStateChanged = (originalPushState != currentSystemPushState)
        let isItemsChanged = !changedItems.isEmpty
        
        guard isPushStateChanged || isItemsChanged else {
            print("Hiçbir değişiklik yok, istek atılmadı.")
            return
        }
        
        var itemsToSend: [NotificationPreferencesItem]? = nil
        
        if isItemsChanged {
            itemsToSend = changedItems.map {
                NotificationPreferencesItem(
                    notificationType: $0.notificationType,
                    channel: $0.channel,
                    enabled: $0.enabled
                )
            }
        }
        
        let request = NotificationPreferencesUpdateRequest(
            pushEnabled: currentSystemPushState,
            items: itemsToSend
        )
        
        do {
            try await service.updateNotificationPreferences(request: request)
        } catch {
            print("Güncelleme hatası: \(error)")
        }
    }
    
    func updateItemState(channel: NotificationPreferencesChannel, isOn: Bool) {
        if let index = currentItems.firstIndex(where: { $0.channel == channel }) {
            let oldItem = currentItems[index]
            let newItem = NotificationPreferencesItem(
                notificationType: oldItem.notificationType,
                channel: oldItem.channel,
                enabled: isOn
            )
            currentItems[index] = newItem
        }
    }
    
    func checkCurrentNotificationState() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let isAuthorized = (settings.authorizationStatus == .authorized)
                self?.currentSystemPushState = isAuthorized
                self?.delegate?.updateSwitchState(isOn: isAuthorized)
                
                // Token yoksa tekrar kayıt ol
                if isAuthorized {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func handleSwitchTap() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

extension NotificationSettingsViewModel: NotificationSettingsViewModelProtocol { }
