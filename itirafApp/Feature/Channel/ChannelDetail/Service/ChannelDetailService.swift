//
//  ChannelDetailService.swift
//  itirafApp
//
//  Created by Emre on 13.11.2025.
//

import Alamofire

protocol ChannelDetailServiceProtocol {
    func fetchConfessions(channelId: Int, page: Int, limit: Int) async throws -> Confession
    func likeConfessions(messageId: Int) async throws
    func unlikeConfessions(messageId: Int) async throws
}

final class ChannelDetailService: ChannelDetailServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchConfessions(channelId: Int, page: Int, limit: Int) async throws -> Confession {
        let parameters: [String: Any] = ["page": page, "limit": limit]
        
        return try await networkService.request(
            endpoint: Endpoint.Channel.getChannelMessages(channelId: channelId),
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
}
