//
//  MyConfessionsService.swift
//  itirafApp
//
//  Created by Emre on 29.10.2025.
//

import Alamofire
import Foundation

protocol MyConfessionsServiceProtocol {
    func fetchMyConfessions(page: Int, limit: Int) async throws -> MyConfession
}

final class MyConfessionsService: MyConfessionsServiceProtocol {
    var networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchMyConfessions(page: Int, limit: Int) async throws -> MyConfession {
        let paramaters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        
        return try await networkService.request(
            endpoint: Endpoint.User.getUserMessages,
            method: .get,
            parameters: paramaters,
            encoding: URLEncoding.default
        )
    }
}
