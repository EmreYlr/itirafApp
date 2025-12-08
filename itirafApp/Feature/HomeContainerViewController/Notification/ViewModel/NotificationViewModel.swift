//
//  NotificationViewModel.swift
//  itirafApp
//
//  Created by Emre on 18.11.2025.
//

protocol NotificationViewModelProtocol {
    var delegate: NotificationViewModelDelegate? { get set }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    func listAllNotifications(reset: Bool) async
    func setSeenAllNotifications() async
    func setSeenNotifications(ids: [String], shouldUpdateUI: Bool) async
    func deleteNotification(ids: [String]) async
    func deleteAllNotifications() async
}

protocol NotificationViewModelDelegate: AnyObject {
    func didUpdateNotifiaction(with data: [NotificationItem])
    func didEmptyNotifications()
    func didFailUpdateNotification(with error: Error)
}

final class NotificationViewModel {
    weak var delegate: NotificationViewModelDelegate?
    var allNotifications: [NotificationItem]?
    
    private(set) var notifications: NotificationModel?
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    private var currentPage = 1
    
    let service: NotificationServiceProtocol
    
    init(service: NotificationServiceProtocol = NotificationService()) {
        self.service = service
    }
    
    func listAllNotifications(reset: Bool = false) async {
        if reset {
            currentPage = 1
            hasMoreData = true
            notifications = nil
        }
        
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newNotification = try await service.listAllNotifications(page: currentPage, limit: 10)
            
            if self.notifications == nil {
                self.notifications = newNotification
            } else {
                let existingIDs = Set(self.notifications?.data.map { $0.id } ?? [])
                let uniqueNewData = newNotification.data.filter { !existingIDs.contains($0.id) }
                self.notifications?.data.append(contentsOf: uniqueNewData)
            }
            
            hasMoreData = currentPage < newNotification.totalPages
            if hasMoreData { currentPage += 1 }
            
            let currentData = notifications?.data ?? []
            if currentData.isEmpty {
                delegate?.didEmptyNotifications()
            } else {
                delegate?.didUpdateNotifiaction(with: currentData)
            }
            
        } catch {
            delegate?.didFailUpdateNotification(with: error)
        }
    }
    
    func setSeenAllNotifications() async {
        do {
            try await service.seenAllNotifications()
            guard let currentData = notifications?.data else { return }
            
            let updatedData = currentData.map { item -> NotificationItem in
                var newItem = item
                newItem.seen = true
                return newItem
            }

            self.notifications?.data = updatedData
            delegate?.didUpdateNotifiaction(with: updatedData)
            
        } catch {
            delegate?.didFailUpdateNotification(with: error)
        }
    }
    
    func setSeenNotifications(ids: [String], shouldUpdateUI: Bool = true) async {
        do {
            try await service.seenNotification(notificationIDS: ids)

            guard let currentData = notifications?.data else { return }
            
            let updatedData = currentData.map { item -> NotificationItem in
                if ids.contains(item.id) {
                    var newItem = item
                    newItem.seen = true
                    return newItem
                }
                return item
            }

            self.notifications?.data = updatedData
            
            if shouldUpdateUI {
                delegate?.didUpdateNotifiaction(with: updatedData)
            }
            
        } catch {
            delegate?.didFailUpdateNotification(with: error)
        }
    }
    
    func deleteNotification(ids: [String]) async {
        do {
            try await service.deleteNotification(notificationIDS: ids)

            guard let currentData = notifications?.data else { return }
            
            let updatedData = currentData.filter { notificationItem in
                return !ids.contains(notificationItem.id)
            }
            self.notifications?.data = updatedData

            if updatedData.isEmpty {
                delegate?.didEmptyNotifications()
            } else {
                delegate?.didUpdateNotifiaction(with: updatedData)
            }
            
        } catch {
            delegate?.didFailUpdateNotification(with: error)
        }
    }
    
    func deleteAllNotifications() async {
        do {
            try await service.deleteAllNotifications()
            self.notifications?.data.removeAll()
            delegate?.didEmptyNotifications()
        } catch {
            delegate?.didFailUpdateNotification(with: error)
        }
    }
}

extension NotificationViewModel: NotificationViewModelProtocol { }
