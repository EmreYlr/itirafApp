//
//  SettingsViewModel.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//

protocol SettingsViewModelProtocol {
    var delegate: SettingsViewModelDelegate? { get set }
    func logout() async
    func checkUserAnonymous() -> Bool
}

protocol SettingsViewModelDelegate: AnyObject {
    func didLogoutSuccessfully()
    func didFailToLogout(with error: Error)
}

final class SettingsViewModel {
    weak var delegate: SettingsViewModelDelegate?
    private let settingsService: SettingsServiceProtocol
    
    init(settingsService: SettingsServiceProtocol = SettingsService()) {
        self.settingsService = settingsService
    }
    
    func logout() async {
        do {
            try await settingsService.logout()
            delegate?.didLogoutSuccessfully()
        } catch {
            delegate?.didFailToLogout(with: error)
        }
    }
    
    
    func checkUserAnonymous() -> Bool {
        return UserManager.shared.getUserIsAnonymous()
    }
}

extension SettingsViewModel: SettingsViewModelProtocol { }
