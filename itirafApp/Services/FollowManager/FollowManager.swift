//
//  FollowManager.swift
//  itirafApp
//
//  Created by Emre on 15.11.2025.
//

import Foundation
import Alamofire

final class FollowManager {
    static let shared = FollowManager()
    
    private let networkService: NetworkService
    private let userDefaults: UserDefaults
    

    private var followedChannelIds: Set<Int> {
        didSet {
            saveToUserDefaults()
        }
    }

    private init(networkService: NetworkService = NetworkManager.shared,
                 userDefaults: UserDefaults = .standard) {
        self.networkService = networkService
        self.userDefaults = userDefaults

        let savedIDs = userDefaults.array(forKey: UserDefaults.Keys.followedChannelIds.rawValue) as? [Int] ?? []
        
        self.followedChannelIds = Set(savedIDs)
    }
        
    private func saveToUserDefaults() {
        let idsToSave = Array(self.followedChannelIds)
        userDefaults.set(idsToSave, forKey: UserDefaults.Keys.followedChannelIds.rawValue)
    }

    func loadFollowedChannels() async throws {
        let channels: [ChannelData] = try await networkService.request(
            endpoint: Endpoint.User.getFollowedChannels,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default
        )

        let ids = channels.map { $0.id }
        self.followedChannelIds = Set(ids)
    }
    
    func followChannels(channelIds: [Int]) async throws {
        let parameters: [String: Any] = [
            "channelIds": channelIds
        ]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.followChannel,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        
        self.followedChannelIds.formUnion(channelIds)
    }

    func unfollowChannel(channelId: Int) async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.unfollowChannel(channelId: channelId),
            method: .delete,
            parameters: nil,
            encoding: URLEncoding.default
        )
        
        self.followedChannelIds.remove(channelId)
    }
    
    func updateCache(with channels: [ChannelData]) {
        let ids = channels.map { $0.id }
        self.followedChannelIds = Set(ids)
    }

    func isChannelFollowed(channelId: Int) -> Bool {
        return followedChannelIds.contains(channelId)
    }

    func clearCache() {
        self.followedChannelIds.removeAll()
    }
}
