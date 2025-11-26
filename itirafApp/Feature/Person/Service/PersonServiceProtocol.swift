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
    func getUserSocialLinks() async throws -> UserSocialLink
    func updateSocialLinkVisibility(id: String, isVisible: Bool) async throws
}

final class PersonService: PersonServiceProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func getUserSocialLinks() async throws -> UserSocialLink {
        return try await networkService.request(
            endpoint: Endpoint.SocialLink.getSocailLinks,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
    
    func updateSocialLinkVisibility(id: String, isVisible: Bool) async throws {
        let parameters: [String: Any] = [
            "visible": isVisible
        ]
        
        let _ :Empty = try await networkService.request(
            endpoint: Endpoint.SocialLink.updateSocialLinkVisibility(socialLinkId: id),
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
}
