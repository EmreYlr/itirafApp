//
//  ChannelDetailViewModel.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

protocol ChannelDetailViewModelProtocol {
    var delegate: ChannelDetailViewModelDelegate? { get set }
    var channel: ChannelData { get set }
    var confessions: Confession? { get }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    func fetchConfessions(reset: Bool) async
    func toggleLikeStatus(for: Int) async
}

protocol ChannelDetailViewModelDelegate: AnyObject {
    func didUpdateConfessions(with data: [ConfessionData])
    func didFailToLikeMessage(with error: Error)
    func didFailWithError(_ error: Error)
}

final class ChannelDetailViewModel {
    weak var delegate: ChannelDetailViewModelDelegate?
    private let service: ChannelDetailServiceProtocol
    var channel: ChannelData
    
    private(set) var confessions: Confession?
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    private var currentPage = 1
    
    init(channel: ChannelData, service: ChannelDetailServiceProtocol = ChannelDetailService()) {
        self.channel = channel
        self.service = service
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
            let newConfessions = try await service.fetchConfessions(channelId: channel.id ,page: currentPage, limit: 10)
            
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
                try await service.unlikeConfessions(messageId: confessionId)
            } else {
                try await service.likeConfessions(messageId: confessionId)
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
    
}

extension ChannelDetailViewModel: ChannelDetailViewModelProtocol {}
