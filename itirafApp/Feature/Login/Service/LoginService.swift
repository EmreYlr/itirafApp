//
//  LoginService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//b
import Alamofire

protocol LoginServiceProtocol {
    func loginUser(email: String, password: String, completion: @escaping (Result<RefreshTokenResponse, Error>) -> Void)
    
}
final class LoginService {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }

    func loginUser(email: String, password: String, completion: @escaping (Result<RefreshTokenResponse, Error>) -> Void) {
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        networkService.request(path: Endpoint.Auth.login, method: .post, parameters: params, encoding: JSONEncoding.default) { (result: Result<RefreshTokenResponse, Error>) in
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

extension LoginService: LoginServiceProtocol { }
