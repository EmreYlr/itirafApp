//
//  EditSocialService.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//

import Alamofire

protocol EditSocialServiceProtocol {
    func addSocialLink(username: String, platform: SocialPlatform) async throws
    func editSocialLink(newUsername: String, socialLink: Link) async throws
    func deleteSocialLink(socialLink: Link) async throws
}

final class EditSocialService: EditSocialServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func addSocialLink(username: String, platform: SocialPlatform) async throws {
        let parameters: [String: Any] = [
            "username": username,
            "platform": platform.rawValue
        ]
        
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.SocialLink.createSocialLink,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
    
    func editSocialLink(newUsername: String ,socialLink: Link) async throws {
        let id = socialLink.id
        let parameters: [String: Any] = [
            "username": newUsername
        ]
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.SocialLink.editSocialLink(socialLinkId: id),
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
    }
    
    func deleteSocialLink(socialLink: Link) async throws {
        let id = socialLink.id
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.SocialLink.deleteSocialLink(socialLinkId: id),
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default
        )
    }
}
