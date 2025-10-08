//
//  ChannelService.swift
//  itirafApp
//
//  Created by Emre on 7.10.2025.
//

import Alamofire

protocol ChannelServiceProtocol {
    func fetchChannels(page: Int, pageSize: Int, completion: @escaping (Result<Channel, Error>) -> Void)
    func searchChannels(query: String, completion: @escaping (Result<[ChannelData], Error>) -> Void)
}

final class ChannelService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }

    func fetchChannels(page: Int, pageSize: Int, completion: @escaping (Result<Channel, any Error>) -> Void) {
        let parameters: [String: Any] = [
            "page": page,
            "limit": pageSize
        ]
        networkService.request(endpoint: Endpoint.Channel.listAllChannels, method: .get, parameters: parameters, encoding: URLEncoding.default) { (result: Result<Channel, Error>) in
            switch result {
            case .success(let channels):
                completion(.success(channels))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func searchChannels(query: String, completion: @escaping (Result<[ChannelData], any Error>) -> Void) {
        let parameters: [String: Any] = [
            "query": query
        ]
        networkService.request(endpoint: Endpoint.Channel.searchChannels, method: .get, parameters: parameters, encoding: URLEncoding.default) { (result: Result<[ChannelData], Error>) in
            switch result {
            case .success(let channel):
                completion(.success(channel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
}

extension ChannelService: ChannelServiceProtocol { }
