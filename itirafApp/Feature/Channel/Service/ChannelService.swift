//
//  ChannelService.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import Alamofire

protocol ChannelServiceProtocol {
    func fetchChannels(page: Int, pageSize: Int) async throws -> Channel
    func searchChannels(query: String) async throws -> [ChannelData]
    func followChannel(channelId: [Int]) async throws
    func unfollowChannel(channelId: Int) async throws
    func getFollowedChannels() async throws -> [ChannelData]
}

final class ChannelService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }

    func fetchChannels(page: Int, pageSize: Int) async throws -> Channel {
        let parameters: [String: Any] = [
            "page": page,
            "limit": pageSize
        ]
        
        return try await networkService.request(
            endpoint: Endpoint.Channel.listAllChannels,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
    }
    
    func searchChannels(query: String) async throws -> [ChannelData] {
        let parameters: [String: Any] = ["query": query]
        
        return try await networkService.request(
            endpoint: Endpoint.Channel.searchChannels,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
    }
    
    func followChannel(channelId: [Int]) async throws {
        let parameters: [String: Any] = [
            "channelIds": channelId
        ]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.followChannel,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
    
    func unfollowChannel(channelId: Int) async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.unfollowChannel(channelId: channelId),
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default
        )
    }
    
    func getFollowedChannels() async throws -> [ChannelData] {
        return try await networkService.request(
            endpoint: Endpoint.User.getFollowedChannels,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
}

extension ChannelService: ChannelServiceProtocol { }
