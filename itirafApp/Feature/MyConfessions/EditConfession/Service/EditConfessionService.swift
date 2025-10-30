//
//  EditConfessionService.swift
//  itirafApp
//
//  Created by Emre on 30.10.2025.
//

import Alamofire

protocol EditConfessionServiceProtocol {
    func editConfession(myConfession: MyConfessionData) async throws
}

final class EditConfessionService: EditConfessionServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func editConfession(myConfession: MyConfessionData) async throws {
        let params: Parameters = [
            "title": myConfession.title,
            "message": myConfession.message
        ]
        
        let messageId = myConfession.id
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.editUserMessage(messageId: messageId),
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default
        )
    }
}
