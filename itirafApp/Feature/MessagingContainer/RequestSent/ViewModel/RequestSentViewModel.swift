//
//  RequestSentViewModel.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//

protocol RequestSentViewModelProtocol {
    var delegate: RequestSentViewModelDelegate? { get set }
    var sentRequests: [RequestSentModel] { get set }
    func fetchSentRequests() async
}

protocol RequestSentViewModelDelegate: AnyObject {
    func didUpdateSentRequests()
    func didError(error: Error)
}

final class RequestSentViewModel {
    weak var delegate: RequestSentViewModelDelegate?
    var sentRequests: [RequestSentModel] = []
    let requestSentService: RequestSentServiceProtocol
    let requestId: String?
    
    init(requestId: String? = nil, requestSentService: RequestSentServiceProtocol = RequestSentService()) {
        self.requestSentService = requestSentService
        self.requestId = requestId
    }
    
    func fetchSentRequests() async {
        do {
            let requests = try await requestSentService.getSentRequests()
            self.sentRequests = requests
            delegate?.didUpdateSentRequests()
        }catch {
            delegate?.didError(error: error)
        }
    }
}

extension RequestSentViewModel: RequestSentViewModelProtocol { }
