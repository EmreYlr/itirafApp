//
//  RequestSentService.swift
//  itirafApp
//
//  Created by Emre on 3.11.2025.
//

import Alamofire

protocol RequestSentServiceProtocol {
    func getSentRequests() async throws -> [RequestSentModel]
    func deleteSentRequest(requestID: String) async throws
}

final class RequestSentService: RequestSentServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func getSentRequests() async throws -> [RequestSentModel] {
        return try await networkService.request(
            endpoint: Endpoint.Room.getSentRequestMessages,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
    
    func deleteSentRequest(requestID: String) async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Room.deleteSentRequestMessages(requestId: requestID),
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default
        )
    }
}
