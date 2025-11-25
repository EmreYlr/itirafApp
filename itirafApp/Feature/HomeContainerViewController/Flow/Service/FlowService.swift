//
//  FlowService.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//
import Alamofire

protocol FlowServiceProtocol {
    func fetchFlow(page: Int, limit: Int) async throws -> Flow
    func likeConfessions(messageId: Int) async throws
    func unlikeConfessions(messageId: Int) async throws
    func setMessagesSeen(_ messageIds: [Int]) async throws
}

final class FlowService: FlowServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchFlow(page: Int, limit: Int) async throws -> Flow {
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        
        return try await networkService.request(
            endpoint: Endpoint.Channel.getFlowMessages,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
    }
    
    func likeConfessions(messageId: Int) async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Channel.likeMessage(messageId: messageId),
            method: .post,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
    
    func unlikeConfessions(messageId: Int) async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Channel.unlikeMessage(messageId: messageId),
            method: .delete,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
    
    func setMessagesSeen(_ messageIds: [Int]) async throws {
        let parameters: [String: Any] = [
            "messageIds": messageIds
        ]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Channel.setMessagesSeen,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
