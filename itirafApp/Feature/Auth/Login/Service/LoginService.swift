//
//  LoginService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire
import Foundation

protocol LoginServiceProtocol {
    func loginUser(email: String, password: String) async throws
}

final class LoginService {
    private let networkService: NetworkService
    private let userService: UserServiceProtocol
    
    init(networkService: NetworkService = NetworkManager.shared,
         userService: UserServiceProtocol = UserService()) {
        self.networkService = networkService
        self.userService = userService
    }

    func loginUser(email: String, password: String) async throws {
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        
        let response: RefreshTokenResponse = try await networkService.request(
            endpoint: Endpoint.Auth.login,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )
        
        AuthManager.shared.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        _ = try await userService.fetchCurrentUser()
    }
}
extension LoginService: LoginServiceProtocol { }
