//
//  HomeService.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import Alamofire
import Foundation

protocol HomeServiceProtocol {
    func fetchConfessions(page: Int, limit: Int) async throws -> Confession
    func likeConfessions(messageId: Int) async throws -> EmptyResponse
    func unlikeConfessions(messageId: Int) async throws -> EmptyResponse
}

final class HomeService: HomeServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchConfessions(page: Int, limit: Int) async throws -> Confession {
        guard let channelId = ChannelManager.shared.getChannelId() else {
            print("Channel ID not found")
            throw AppError.channelIdNotFound
        }
        
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        
        return try await networkService.request(
            endpoint: Endpoint.Channel.getChannelMessages(channelId: channelId),
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
    }
    
    func likeConfessions(messageId: Int) async throws -> EmptyResponse {
        return try await networkService.request(
            endpoint: Endpoint.Channel.likeMessage(messageId: messageId),
            method: .post,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
    
    func unlikeConfessions(messageId: Int) async throws -> EmptyResponse {
        return try await networkService.request(
            endpoint: Endpoint.Channel.unlikeMessage(messageId: messageId),
            method: .delete,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
}
