//
//  DetailService.swift
//  itirafApp
//
//  Created by Emre on 6.10.2025.
//


import Alamofire

protocol DetailServiceProtocol {
//    func fetchDetail(messageId: String, completion: @escaping (Result<Confession, Error>) -> Void)
}

final class DetailService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }

    
    
}

extension DetailService: DetailServiceProtocol { }
