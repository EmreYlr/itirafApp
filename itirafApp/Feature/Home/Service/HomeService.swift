//
//  HomeService.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import Alamofire
import Foundation

protocol HomeServiceProtocol {
//    func likeConfessions(confession: Confession, completion: @escaping (Result<[Confession], Error>) -> Void)
    func fetchConfessions(page: Int, limit: Int, completion: @escaping (Result<Confession, Error>) -> Void)
}

final class HomeService: HomeServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Methods
//    func likeConfessions(confession: Confession, completion: @escaping (Result<[Confession], Error>) -> Void) {
//        let params: Parameters = [
//            "confessionId": confession.id
//        ]
//        networkService.request(endpoint: Endpoint.Confession.likePost, method: .post, parameters: params, encoding: URLEncoding.default) { (result: Result<[Confession], Error>) in
//            switch result {
//            case .success(let confessions):
//                completion(.success(confessions))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
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
}
