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

    private var followedChannels: Set<ChannelData> {
        didSet {
            saveToUserDefaults()
        }
    }


    private init(networkService: NetworkService = NetworkManager.shared, userDefaults: UserDefaults = .standard) {
        self.networkService = networkService
        self.userDefaults = userDefaults

        if let savedData = userDefaults.data(forKey: .followedChannels),
           let channels = try? JSONDecoder().decode([ChannelData].self, from: savedData) {
            self.followedChannels = Set(channels)
        } else {
            self.followedChannels = []
        }
    }

    private func saveToUserDefaults() {
        let channelsToSave = Array(self.followedChannels)
        
        if let dataToSave = try? JSONEncoder().encode(channelsToSave) {
            userDefaults.set(dataToSave, forKey: .followedChannels)
        } else {
            print("FollowManager Hata: Takip edilen kanallar UserDefaults'e kaydedilemedi.")
        }
    }

    func loadFollowedChannels() async throws {
        let channels: [ChannelData] = try await networkService.request(
            endpoint: Endpoint.User.getFollowedChannels,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default
        )

        self.followedChannels = Set(channels)
    }

    func followChannel(channel: ChannelData) async throws {
        let parameters: [String: Any] = [
            "channelIds": [channel.id]
        ]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.followChannel,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        
        self.followedChannels.insert(channel)
    }

    func unfollowChannel(channel: ChannelData) async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.unfollowChannel(channelId: channel.id),
            method: .delete,
            parameters: nil,
            encoding: URLEncoding.default
        )
        self.followedChannels.remove(channel)
    }
    
    func getCachedFollowedChannels() -> [ChannelData] {
        return Array(self.followedChannels)
    }

    func updateCache(with channels: [ChannelData]) {
        self.followedChannels = Set(channels)
    }

    func isChannelFollowed(channelId: Int) -> Bool {
        return followedChannels.contains { $0.id == channelId }
    }
    
    func isChannelEmpty() -> Bool {
        return followedChannels.isEmpty
    }

    func clearCache() {
        self.followedChannels.removeAll()
    }
}
