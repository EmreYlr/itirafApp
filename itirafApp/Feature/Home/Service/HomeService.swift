//
//  HomeService.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import Alamofire
import Foundation

protocol HomeServiceProtocol {
    func fetchConfessions(page: Int, limit: Int, completion: @escaping (Result<Confession, Error>) -> Void)
    func likeConfessions(messageId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void)
    func unlikeConfessions(messageId: Int, completion: @escaping (Result<EmptyResponse, any Error>) -> Void)
}

final class HomeService: HomeServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchConfessions(page: Int, limit: Int, completion: @escaping (Result<Confession, Error>) -> Void) {
        guard let channelId = ChannelManager.shared.getChannelId() else {
            print("Channel ID not found")
            completion(.failure(NSError(domain: "AppError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Channel ID not found"])))
            return
        }
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        
        networkService.request(endpoint: Endpoint.Channel.getChannelMessages(channelId: channelId), method: .get, parameters: parameters, encoding: URLEncoding.default) { (result: Result<Confession, Error>) in
            switch result {
            case .success(let confessions):
                completion(.success(confessions))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func likeConfessions(messageId: Int, completion: @escaping (Result<EmptyResponse, any Error>) -> Void) {
        networkService.request(endpoint: Endpoint.Channel.likeMessage(messageId: messageId), method: .post, parameters: nil, encoding: URLEncoding.default) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func unlikeConfessions(messageId: Int, completion: @escaping (Result<EmptyResponse, any Error>) -> Void) {
        networkService.request(endpoint: Endpoint.Channel.unlikeMessage(messageId: messageId), method: .delete, parameters: nil, encoding: URLEncoding.default) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}
