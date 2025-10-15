//
//  DetailService.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//


import Alamofire
import Foundation

protocol DetailServiceProtocol {
    func fetchDetail(messageId: Int, completion: @escaping (Result<ChannelMessageData, Error>) -> Void)
    func likeConfessions(messageId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void)
    func unlikeConfessions(messageId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void)

}

final class DetailService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchDetail(messageId: Int, completion: @escaping (Result<ChannelMessageData, Error>) -> Void) {
        guard let channelId = ChannelManager.shared.getChannelId() else {
            print("Channel ID not found")
            completion(.failure(NSError(domain: "AppError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Channel ID not found"])))
            return
        }
        
        networkService.request(endpoint: Endpoint.Channel.getChannelSpecificMessages(channelId: channelId, messageId: messageId), method: .get, parameters: nil, encoding: URLEncoding.default) { (result: Result<ChannelMessageData, Error>) in
            switch result {
            case .success(let messageDetail):
                completion(.success(messageDetail))
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

extension DetailService: DetailServiceProtocol { }
