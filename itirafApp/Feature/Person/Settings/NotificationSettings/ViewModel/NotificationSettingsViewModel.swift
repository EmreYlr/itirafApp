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
}

protocol NotificationSettingsViewModelDelegate: AnyObject {
    func updateSwitchState(isOn: Bool)
}

final class NotificationSettingsViewModel {
    var delegate: NotificationSettingsViewModelDelegate?
    
    func checkCurrentNotificationState() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let isAuthorized = (settings.authorizationStatus == .authorized)
                self?.delegate?.updateSwitchState(isOn: isAuthorized)
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
