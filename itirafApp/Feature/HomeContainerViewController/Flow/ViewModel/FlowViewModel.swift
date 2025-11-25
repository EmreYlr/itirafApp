//
//  FlowViewModel.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

protocol FlowViewModelProtocol {
    var delegate: FlowViewModelDelegate? { get set }
    var flow: Flow? { get }
    var isLoading: Bool { get }
    var hasMoreData: Bool { get }
    func fetchFlow(reset: Bool) async
    func toggleLikeStatus(for: Int) async
    func didViewItem(at id: Int)
    func sendPendingSeenMessages()
}

protocol FlowViewModelDelegate: AnyObject {
    func didUpdateFlow(with data: [FlowData])
    func didFailToLikeMessage(with error: Error)
    func didFailWithError(_ error: Error)
}

final class FlowViewModel {
    weak var delegate: FlowViewModelDelegate?
    let flowService: FlowServiceProtocol
    
    private(set) var flow: Flow?
    private(set) var isLoading = false
    private(set) var hasMoreData = true
    private var currentPage = 1
    
    private var processedMessageIds: Set<Int> = []
    private var pendingMessageIds: [Int] = []
    private let batchThreshold = 15
    
    init(flowService: FlowServiceProtocol = FlowService()) {
        self.flowService = flowService
    }
    
    func fetchFlow(reset: Bool = false) async {
        if reset {
            currentPage = 1
            hasMoreData = true
            flow = nil
        }
        
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newFlow = try await flowService.fetchFlow(page: currentPage, limit: 10)
            
            if self.flow == nil {
                self.flow = newFlow
            } else {
                self.flow?.data.append(contentsOf: newFlow.data)
            }
            
            hasMoreData = currentPage < newFlow.totalPages
            if hasMoreData { currentPage += 1 }
            
            delegate?.didUpdateFlow(with: flow?.data ?? [])
            
        } catch {
            delegate?.didFailWithError(error)
        }
    }
    
    func toggleLikeStatus(for flowId: Int) async {
        guard let index = flow?.data.firstIndex(where: { $0.id == flowId }) else { return }
        
        let isLiked = flow?.data[index].liked == true
        toggleLocalLike(for: flowId)
        
        do {
            if isLiked {
                try await flowService.unlikeConfessions(messageId: flowId)
            } else {
                try await flowService.likeConfessions(messageId: flowId)
            }
        } catch {
            print("Error toggling like status: \(error)")
            toggleLocalLike(for: flowId)
            delegate?.didFailToLikeMessage(with: error)
        }
    }
    
    private func toggleLocalLike(for flowId: Int) {
        guard let index = flow?.data.firstIndex(where: { $0.id == flowId }) else { return }
        
        flow?.data[index].liked.toggle()
        let isNowLiked = flow?.data[index].liked == true

        if isNowLiked {
            flow?.data[index].likeCount += 1
        } else {
            flow?.data[index].likeCount -= 1
        }
        
        if let updatedData = flow?.data {
            delegate?.didUpdateFlow(with: updatedData)
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
            try await flowService.setMessagesSeen(messageId)
            print("Görüldü gönderildi: \(messageId.count) adet")
        } catch {
            print("Görüldü hatası: \(error)")
        }
    }
}

extension FlowViewModel: FlowViewModelProtocol { }
