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
    func likeConfessions(messageId: Int) async throws
    func unlikeConfessions(messageId: Int) async throws
}

final class HomeService: HomeServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchConfessions(page: Int, limit: Int) async throws -> Confession {
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        //TODO: -getFollowedChannelsMessages eklendi onu bi kontrol et
        return try await networkService.request(
            endpoint: Endpoint.User.getFollowedChannelsMessages,
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
