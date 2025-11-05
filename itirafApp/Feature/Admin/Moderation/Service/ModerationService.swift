//
//  ModerationService.swift
//  itirafApp
//
//  Created by Emre on 5.11.2025.
//
import Alamofire

protocol ModerationServiceProtocol {
    func getModerationData(page: Int, limit: Int) async throws -> ModerationModel
}

final class ModerationService: ModerationServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func getModerationData(page: Int, limit: Int) async throws -> ModerationModel {
        
        let parameters: [String: Any] = [
            "page": page,
            "limit": limit
        ]
        
        return try await networkService.request(
            endpoint: Endpoint.Admin.getModerationMessages,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default
        )
    }
}
