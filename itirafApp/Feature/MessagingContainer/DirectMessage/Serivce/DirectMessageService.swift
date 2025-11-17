//
//  DirectMessageService.swift
//  itirafApp
//
//  Created by Emre on 22.10.2025.
//

import Alamofire

protocol DirectMessageServiceProtocol {
    func getAllRoom() async throws -> [DirectMessage]
    func deleteRoom(roomId: String, blockUser: Bool) async throws
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
    
    func deleteRoom(roomId: String, blockUser: Bool) async throws {
        let parameters: [String: Any] = [
            "blockUser": blockUser
        ]
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.Room.deleteRoom(roomId: roomId),
            method: .delete,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
