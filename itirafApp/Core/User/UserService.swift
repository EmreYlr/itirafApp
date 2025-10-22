//
//  UserService.swift
//  itirafApp
//
//  Created by Emre on 3.10.2025.
//

import Foundation
import Alamofire

// MARK: - UserService

protocol UserServiceProtocol {
    func fetchCurrentUser() async throws -> User
}

final class UserService: UserServiceProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchCurrentUser() async throws -> User {
        let user: User = try await networkService.request(
            endpoint: Endpoint.User.me,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default
        )
        
        UserManager.shared.setUser(user)
        return user
    }
}
