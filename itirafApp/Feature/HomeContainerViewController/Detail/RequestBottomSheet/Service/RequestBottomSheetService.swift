//
//  RequestBottomSheetService.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//

import Alamofire

protocol RequestBottomSheetServiceProtocol {
    func sendRequest(message: String, channelMessageId: Int, shareSocialLinks: Bool) async throws
}

final class RequestBottomSheetService: RequestBottomSheetServiceProtocol {
    let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func sendRequest(message: String, channelMessageId: Int, shareSocialLinks: Bool) async throws {
        let parameters: [String: Any] = [
            "initialMessage": message,
            "channelMessageId": channelMessageId,
            "shareSocialLinks": shareSocialLinks
        ]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Room.createRequestMessage,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
