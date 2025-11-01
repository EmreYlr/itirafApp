//
//  RequestMessageViewModel.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//

protocol RequestMessageViewModelProtocol {
    var delegate: RequestMessageViewModelDelegate? { get set }
    var requestMessageModel: [RequestMessageModel] { get set }
    func getPendingMessages() async
    func approveRequest(requestID: String) async
    func rejectRequest(requestID: String) async
}

protocol RequestMessageViewModelDelegate: AnyObject {
    func didUpdateRequestMessages()
    func didApproveRequest(requestID: String)
    func didRejectRequest(requestID: String)
    func didError(with error: Error)
}

final class RequestMessageViewModel {
    weak var delegate: RequestMessageViewModelDelegate?
    var requestMessageModel: [RequestMessageModel] = []
    let requestMessageService: RequestMessageServiceProtocol
    
    init(requestMessageService: RequestMessageServiceProtocol = RequestMessageService()) {
        self.requestMessageService = requestMessageService
    }
    
    func getPendingMessages() async {
        do {
            let messages = try await requestMessageService.fetchPendingMessages()
            self.requestMessageModel = messages
            delegate?.didUpdateRequestMessages()
        } catch {
            delegate?.didError(with: error)
        }
    }
    
    func approveRequest(requestID: String) async {
        do {
            try await requestMessageService.approveRequest(requestID: requestID)
            delegate?.didApproveRequest(requestID: requestID)
        } catch {
            delegate?.didError(with: error)
        }
    }
    
    func rejectRequest(requestID: String) async {
        do {
            try await requestMessageService.rejectRequest(requestID: requestID)
            delegate?.didRejectRequest(requestID: requestID)
        } catch {
            delegate?.didError(with: error)
        }
    }
    
}

extension RequestMessageViewModel: RequestMessageViewModelProtocol { }
