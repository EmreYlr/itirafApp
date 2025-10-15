//
//  PostConfessionService.swift
//  itirafApp
//
//  Created by Emre on 15.10.2025.
//
import Foundation
import Alamofire

protocol PostConfessionServiceProtocol {
    func postConfession(content: PostConfession, completion: @escaping (Result<EmptyResponse, Error>) -> Void)
}

final class PostConfessionService {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func postConfession(content: PostConfession, completion: @escaping (Result<EmptyResponse, any Error>) -> Void) {
        guard let channelId = ChannelManager.shared.getChannelId() else {
            print("Channel ID not found")
            completion(.failure(NSError(domain: "AppError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Channel ID not found"])))
            return
        }
        
        let parameters: [String: Any] = [
            "title": content.title,
            "message": content.message
        ]
        
        networkService.request(endpoint: Endpoint.Channel.postChannelMessages(channelId: channelId), method: .post, parameters: parameters, encoding: JSONEncoding.default) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

extension PostConfessionService: PostConfessionServiceProtocol { }
