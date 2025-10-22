//
//  PostConfessionService.swift
//  itirafApp
//
//  Created by Emre on 15.10.2025.
//
import Foundation
import Alamofire

protocol PostConfessionServiceProtocol {
    func postConfession(content: PostConfession) async throws
}

final class PostConfessionService {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func postConfession(content: PostConfession) async throws {
        guard let channelId = ChannelManager.shared.getChannelId() else {
            print("Channel ID not found")
            throw AppError.channelIdNotFound
        }
        
        let parameters: [String: Any] = [
            "title": content.title,
            "message": content.message
        ]

        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Channel.postChannelMessages(channelId: channelId),
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}

extension PostConfessionService: PostConfessionServiceProtocol { }
