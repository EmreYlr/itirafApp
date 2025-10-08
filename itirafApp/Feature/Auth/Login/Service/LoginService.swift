//
//  LoginService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire

protocol LoginServiceProtocol {
    func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    
}

final class LoginService {
    private let networkService: NetworkService
    private let userService: UserService
    
    init(networkService: NetworkService = NetworkManager.shared,
         userService: UserService = UserService()) {
        self.networkService = networkService
        self.userService = userService
    }

    func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        networkService.request(endpoint: Endpoint.Auth.login, method: .post, parameters: params, encoding: JSONEncoding.default) { [weak self] (result: Result<RefreshTokenResponse, Error>) in
            switch result {
            case .success(let response):
                //TODO: -Thread Performance Checker uyarısına bak
                AuthManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )

                self?.userService.fetchCurrentUser { userResult in
                    switch userResult {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}

extension LoginService: LoginServiceProtocol { }
