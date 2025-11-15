//
//  FollowChannelService.swift
//  itirafApp
//
//  Created by Emre on 15.11.2025.
//

import Alamofire

protocol FollowChannelServiceProtocol {
    func getFollowedChannels() async throws -> [ChannelData]
    func unfollowChannel(channelId: Int) async throws
    func followChannel(channelId: [Int]) async throws
}

final class FollowChannelService: FollowChannelServiceProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func getFollowedChannels() async throws -> [ChannelData] {
        return try await networkService.request(
            endpoint: Endpoint.User.getFollowedChannels,
            method: .get,
            parameters: nil,
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
}
