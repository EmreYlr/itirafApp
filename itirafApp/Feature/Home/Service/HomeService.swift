//
//  HomeService.swift
//  itirafApp
//
//  Created by Emre on 29.09.2025.
//

import Alamofire

protocol HomeServiceProtocol {
    func likeConfessions(confession: Confession, completion: @escaping (Result<[Confession], Error>) -> Void)
    func fetchConfessions(completion: @escaping (Result<[Confession], Error>) -> Void)
}

final class HomeService: HomeServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Methods
    func likeConfessions(confession: Confession, completion: @escaping (Result<[Confession], Error>) -> Void) {
        let params: Parameters = [
            "confessionId": confession.id
        ]
        networkService.request(endpoint: Endpoint.Confession.likePost, method: .post, parameters: params, encoding: URLEncoding.default) { (result: Result<[Confession], Error>) in
            switch result {
            case .success(let confessions):
                completion(.success(confessions))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchConfessions(completion: @escaping (Result<[Confession], Error>) -> Void) {
        networkService.request(endpoint: Endpoint.Confession.all, method: .get, parameters: nil, encoding: URLEncoding.default) { (result: Result<[Confession], Error>) in
            switch result {
            case .success(let confessions):
                completion(.success(confessions))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
