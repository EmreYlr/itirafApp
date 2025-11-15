//
//  FollowChannelService.swift
//  itirafApp
//
//  Created by Emre on 15.11.2025.
//

import Alamofire

protocol FollowChannelServiceProtocol {
    func getFollowedChannels() async throws -> [ChannelData]
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
}
