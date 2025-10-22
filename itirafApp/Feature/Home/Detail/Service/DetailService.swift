//
//  DetailService.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//

import Alamofire
import Foundation

protocol DetailServiceProtocol {
    func fetchDetail(messageId: Int) async throws -> ChannelMessageData
    func likeConfessions(messageId: Int) async throws
    func unlikeConfessions(messageId: Int) async throws
    func repliesMessage(message: String, messageId: Int) async throws
}

final class DetailService: DetailServiceProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchDetail(messageId: Int) async throws -> ChannelMessageData {
        return try await networkService.request(
            endpoint: Endpoint.Channel.getChannelSpecificMessages(messageId: messageId),
            method: .get,
            parameters: nil,
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
    
    func repliesMessage(message: String, messageId: Int) async throws {
        let parameters: [String: Any] = ["message": message]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Channel.repliesMessage(messageId: messageId),
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
