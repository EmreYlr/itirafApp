//
//  LoginService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire

protocol RegisterServiceProtocol {
    func registerUser(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void)
    
}

final class RegisterService {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }

    func registerUser(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let params: Parameters = [
            "email": email,
            "username": username,
            "password": password
        ]
        
        networkService.request(endpoint: Endpoint.Auth.register, method: .post, parameters: params, encoding: JSONEncoding.default) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension RegisterService: RegisterServiceProtocol { }




