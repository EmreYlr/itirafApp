//
//  LoginService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire

protocol RegisterServiceProtocol {
    func registerUser(email: String, password: String, username: String, completion: @escaping (Result<RefreshTokenResponse, Error>) -> Void)
    
}

final class RegisterService {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }

    func registerUser(email: String, password: String, username: String, completion: @escaping (Result<RefreshTokenResponse, Error>) -> Void) {
        let params: Parameters = [
            "email": email,
            "password": password,
            "username": username
        ]
        networkService.request(endpoint: Endpoint.Auth.register, method: .post, parameters: params, encoding: JSONEncoding.default) { (result: Result<RefreshTokenResponse, Error>) in
            switch result {
            case .success(let response):
                AuthManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension RegisterService: RegisterServiceProtocol { }
