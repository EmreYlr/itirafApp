//
//  UserService.swift
//  itirafApp
//
//  Created by Emre on 3.10.2025.
//

import Alamofire

// MARK: - UserService
final class UserService {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        networkService.request(endpoint: Endpoint.User.me, method: .get, parameters: nil, encoding: URLEncoding.default) {
            (result: Result<User, Error>) in
            switch result {
            case .success(let user):
                UserManager.shared.clear()
                UserManager.shared.setUser(user)
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
