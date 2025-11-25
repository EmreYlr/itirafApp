//
//  HomeViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//
import Foundation

protocol HomeViewModelProtocol {
    var delegate: HomeViewModelOutputProtocol? { get set }
    var confessions: Confession? { get }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    func fetchConfessions(reset: Bool) async
    func toggleLikeStatus(for: Int) async
    func didViewItem(at id: Int)
    func sendPendingSeenMessages()
}

protocol HomeViewModelOutputProtocol: AnyObject {
    func didUpdateConfessions(with data: [ConfessionData])
    func didFailToLikeMessage(with error: Error)
    func didFailWithError(_ error: Error)
}

final class HomeViewModel {
    weak var delegate: HomeViewModelOutputProtocol?
    let homeService: HomeServiceProtocol
    
    private(set) var confessions: Confession?
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    private var currentPage = 1
    
    private var processedMessageIds: Set<Int> = []
    private var pendingMessageIds: [Int] = []
    private let batchThreshold = 15
    
    init(homeService: HomeServiceProtocol = HomeService()) {
        self.homeService = homeService
    }
    
    func fetchConfessions(reset: Bool = false) async {
        if reset {
            currentPage = 1
            hasMoreData = true
            confessions = nil
        }
        
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newConfessions = try await homeService.fetchConfessions(page: currentPage, limit: 10)
            
            if self.confessions == nil {
                self.confessions = newConfessions
            } else {
                self.confessions?.data.append(contentsOf: newConfessions.data)
            }
            
            hasMoreData = currentPage < newConfessions.totalPages
            if hasMoreData { currentPage += 1 }
            
            delegate?.didUpdateConfessions(with: confessions?.data ?? [])
            
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func toggleLikeStatus(for confessionId: Int) async {
        guard let index = confessions?.data.firstIndex(where: { $0.id == confessionId }) else { return }
        
        let isLiked = confessions?.data[index].liked == true
        toggleLocalLike(for: confessionId)
        
        do {
            if isLiked {
                try await homeService.unlikeConfessions(messageId: confessionId)
            } else {
                try await homeService.likeConfessions(messageId: confessionId)
            }
        } catch {
            print("Error toggling like status: \(error)")
            toggleLocalLike(for: confessionId)
            delegate?.didFailToLikeMessage(with: error)
        }
    }
    
    private func toggleLocalLike(for confessionId: Int) {
        guard let index = confessions?.data.firstIndex(where: { $0.id == confessionId }) else { return }
        
        confessions?.data[index].liked.toggle()
        let isNowLiked = confessions?.data[index].liked == true

        if isNowLiked {
            confessions?.data[index].likeCount += 1
        } else {
            confessions?.data[index].likeCount -= 1
        }
        
        if let updatedData = confessions?.data {
            delegate?.didUpdateConfessions(with: updatedData)
        }
    }
    
    func didViewItem(at id: Int) {
        if !processedMessageIds.contains(id) {
            processedMessageIds.insert(id)
            pendingMessageIds.append(id)
            
            if pendingMessageIds.count >= batchThreshold {
                sendPendingSeenMessages()
            }
        }
    }
    
    func sendPendingSeenMessages() {
        guard !pendingMessageIds.isEmpty else { return }
        
        let idsToSend = pendingMessageIds
        pendingMessageIds.removeAll()
        
        Task {
            await markAsRead(messageId: idsToSend)
        }
    }
    
    private func markAsRead(messageId: [Int]) async {
        do {
            try await homeService.setMessagesSeen(messageId)
        } catch {
            print("Görüldü hatası: \(error)")
        }
    }
}

extension HomeViewModel: HomeViewModelProtocol {}
