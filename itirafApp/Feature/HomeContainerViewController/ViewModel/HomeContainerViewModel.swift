//
//  HomeContainerViewModel.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//

protocol HomeContainerViewModelProtocol {
    var delegate: HomeContainerViewModelDelegate? { get set }
    var notificationStatus: NotificationStatus? { get }
    func getNotificationStatus() async
    func isUserAnonymous() -> Bool
}

protocol HomeContainerViewModelDelegate: AnyObject {
    func didUpdateNotificationStatus(_ status: NotificationStatus)
    func didFailToUpdateNotificationStatus()
}

final class HomeContainerViewModel {
    weak var delegate: HomeContainerViewModelDelegate?
    var notificationStatus: NotificationStatus?
    
    let service: HomeContainerServiceProtocol
    
    init(service: HomeContainerServiceProtocol = HomeContainerService()) {
        self.service = service
    }
    
    func getNotificationStatus() async {
        if !UserManager.shared.getUserIsAnonymous() {
            do {
                let status = try await service.fetchNotificationStatus()
                self.notificationStatus = status
                delegate?.didUpdateNotificationStatus(status)
            } catch {
                delegate?.didFailToUpdateNotificationStatus()
            }
        }
    }
    
    func isUserAnonymous() -> Bool {
        return UserManager.shared.getUserIsAnonymous()
    }
}

extension HomeContainerViewModel: HomeContainerViewModelProtocol { }
