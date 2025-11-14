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
}

final class PersonService: PersonServiceProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    //TODO: -Takipçileri görme ekle
    func getUserSocialLinks() async throws -> UserSocialLink {
        return try await networkService.request(
            endpoint: Endpoint.SocialLink.getSocailLinks,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default
        )
    }
}
