//
//  Person
//  PersonServiceProtocol.swift
//  itirafApp
//
//  Created by Emre on 3.10.2025.
//

import Alamofire

protocol PersonServiceProtocol {
    func logout(completion: @escaping (Result<Bool, Error>) -> Void)
}

final class PersonService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func logout(completion: @escaping (Result<Bool, any Error>) -> Void) {
        networkService.request(endpoint: Endpoint.Auth.logout, method: .delete, parameters: nil, encoding: URLEncoding.default) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success:
                AuthManager.shared.clearTokens()
                UserManager.shared.clear()
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension PersonService: PersonServiceProtocol { }
