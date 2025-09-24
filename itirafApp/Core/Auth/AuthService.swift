//
//  AuthService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Foundation
import Alamofire

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

final class AuthService {
    static func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refresh = AuthManager.shared.getRefreshToken() else {
            completion(false)
            return
        }

        let params: Parameters = ["refresh_token": refresh]

        NetworkManager.shared.request( path: Endpoint.Auth.refreshToken, method: .post, parameters: params, encoding: JSONEncoding.default) { (result: Result<RefreshTokenResponse, Error>) in
            switch result {
            case .success(let response):
                AuthManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
}

