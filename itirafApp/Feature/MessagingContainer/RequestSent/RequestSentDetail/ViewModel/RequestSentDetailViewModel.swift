//
//  RequestSentDetailViewModel.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//
import Foundation

protocol RequestSentDetailViewModelProtocol {
    var delegate: RequestSentDetailViewModelDelegate? { get set }
    var sentRequests: RequestSentModel? { get set }
    func deleteSentRequest() async
}

protocol RequestSentDetailViewModelDelegate: AnyObject {
    func didDeleteSentRequests()
    func didError(error: Error)
}

final class RequestSentDetailViewModel {
    weak var delegate: RequestSentDetailViewModelDelegate?
    var sentRequests: RequestSentModel?
    let requestSentService: RequestSentServiceProtocol
    
    init(requestSentService: RequestSentServiceProtocol = RequestSentService()) {
        self.requestSentService = requestSentService
    }
    
    func deleteSentRequest() async {
        guard let requestID = sentRequests?.requestID else { return }
        do {
            try await requestSentService.deleteSentRequest(requestID: requestID)
            delegate?.didDeleteSentRequests()
        }catch {
            delegate?.didError(error: error)
        }
    }
}

extension RequestSentDetailViewModel: RequestSentDetailViewModelProtocol { }
