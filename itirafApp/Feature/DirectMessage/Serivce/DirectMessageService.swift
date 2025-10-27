//
//  DirectMessageService.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

import Alamofire

protocol DirectMessageServiceProtocol {
    func getAllRoom() async throws -> [DirectMessage]
}

final class DirectMessageService: DirectMessageServiceProtocol {
    private let networkService: NetworkService

    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func getAllRoom() async throws -> [DirectMessage] {
        return try await networkService.request(
            endpoint: Endpoint.Room.getAllRoom,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default)
    }
}
