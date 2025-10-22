//
//  LoginService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire
import Foundation

protocol RegisterServiceProtocol {
    func registerUser(email: String, password: String, username: String) async throws
}

final class RegisterService {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }

    func registerUser(email: String, password: String, username: String) async throws {
        let params: Parameters = [
            "email": email,
            "username": username,
            "password": password
        ]

        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Auth.register,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )
    }
}
extension RegisterService: RegisterServiceProtocol { }
