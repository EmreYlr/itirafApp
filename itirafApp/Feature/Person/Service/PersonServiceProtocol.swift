//
//  Person
//  PersonServiceProtocol.swift
//  itirafApp
//
//  Created by Emre on 3.10.2025.
//

import Alamofire
import Foundation

protocol PersonServiceProtocol {
    func logout() async throws
}

final class PersonService: PersonServiceProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func logout() async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.Auth.logout,
            method: .delete,
            parameters: nil,
            encoding: URLEncoding.default
        )
        AuthManager.shared.clearTokens()
        UserManager.shared.clear()
    }
}
