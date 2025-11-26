//
//  RequestBottomSheetViewModel.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//
// RequestBottomSheetViewModel.swift

protocol RequestBottomSheetViewModelProtocol {
    var delegate: RequestBottomSheetViewModelDelegate? { get set }
    var channelMessageId: Int? { get set }
    func sendRequest(message: String, shareSocialLinks: Bool) async
}

protocol RequestBottomSheetViewModelDelegate: AnyObject {
    func didSendRequestSuccessfully()
    func didFailToSendRequest(with error: Error)
}

final class RequestBottomSheetViewModel {
    weak var delegate: RequestBottomSheetViewModelDelegate?
    var channelMessageId: Int?
    let requestBottomSheetService: RequestBottomSheetServiceProtocol

    init(requestBottomSheetService: RequestBottomSheetServiceProtocol = RequestBottomSheetService(), channelMessageId: Int) {
        self.requestBottomSheetService = requestBottomSheetService
        self.channelMessageId = channelMessageId
    }
    
    init(requestBottomSheetService: RequestBottomSheetServiceProtocol = RequestBottomSheetService()) {
        self.requestBottomSheetService = requestBottomSheetService
    }
    
    func sendRequest(message: String, shareSocialLinks: Bool = true) async {
        guard let channelMessageId = channelMessageId else {
            return
        }
        
        do {
            try await requestBottomSheetService.sendRequest(message: message, channelMessageId: channelMessageId, shareSocialLinks: shareSocialLinks)
            delegate?.didSendRequestSuccessfully()
        } catch {
            delegate?.didFailToSendRequest(with: error)
        }
    }
}

extension RequestBottomSheetViewModel: RequestBottomSheetViewModelProtocol { }
