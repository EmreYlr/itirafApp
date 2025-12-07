//
//  EditProfileService.swift
//  itirafApp
//
//  Created by Emre on 7.12.2025.
//
import Alamofire

protocol EditProfileServiceProtocol {
    func deleteAccount() async throws
}

final class EditProfileService: EditProfileServiceProtocol {
    let networkService: NetworkService
    private let followManager: FollowManager
    
    init(networkService: NetworkService = NetworkManager.shared, followManager: FollowManager = FollowManager.shared) {
        self.networkService = networkService
        self.followManager = followManager
    }
    
    func deleteAccount() async throws {
        let _: Empty = try await networkService.request(
            endpoint: Endpoint.User.deleteAccount,
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default
        )

        CrashlyticsManager.shared.setUserID("none")
        CrashlyticsManager.shared.isUserAnonymous(true)
        
        ClarityManager.shared.clearUser()
        
        AuthManager.shared.clearTokens()
        UserManager.shared.clear()
        
        followManager.clearCache()
    }
}
