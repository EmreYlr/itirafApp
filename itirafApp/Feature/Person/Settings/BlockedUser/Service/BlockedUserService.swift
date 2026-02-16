//
//  BlockedUserService.swift
//  itirafApp
//
//  Created by Emre on 16.02.2026.
//

import Alamofire

protocol BlockedUserServiceProtocol {
    func fetchBlockedUsers() async throws -> [BlockedUser]
    func unblockUser(userId: String) async throws
}

final class BlockedUserService: BlockedUserServiceProtocol {
    var networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func fetchBlockedUsers() async throws -> [BlockedUser] {
        return try await networkService.request(
            endpoint: Endpoint.User.getBlockUsers,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
    
    func unblockUser(userId: String) async throws {
        let parameters: [String: Any] = [
            "userId": userId
        ]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.unblockUsers,
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
