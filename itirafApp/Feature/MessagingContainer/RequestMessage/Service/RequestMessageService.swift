//
//  RequestMessageService.swift
//  itirafApp
//
//  Created by Emre on 1.11.2025.
//

import Alamofire

protocol RequestMessageServiceProtocol {
    func fetchPendingMessages() async throws -> [RequestMessageModel]
    func approveRequest(requestID: String) async throws
    func rejectRequest(requestID: String) async throws
}

final class RequestMessageService: RequestMessageServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchPendingMessages() async throws -> [RequestMessageModel] {
        return try await networkService.request(
            endpoint: Endpoint.Room.getPendingMessages,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
    
    func approveRequest(requestID: String) async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Room.approveRequest(requestId: requestID),
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default
        )
    }
    
    func rejectRequest(requestID: String) async throws {
        let _: Empty =  try await networkService.request(
            endpoint: Endpoint.Room.rejectRequest(requestId: requestID),
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default
        )
    }
}
