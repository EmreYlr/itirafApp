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
        let channelId = content.channelId
        
        var parameters: [String: Any] = [
            "message": content.message
        ]
        
        if let title = content.title {
            parameters["title"] = title
        }

        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Channel.postChannelMessages(channelId: channelId),
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}

extension PostConfessionService: PostConfessionServiceProtocol { }
