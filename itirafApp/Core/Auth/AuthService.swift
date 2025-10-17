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
    private static func registerAnonymousUser() async throws -> User {
        let user: User = try await NetworkManager.shared.request(
            endpoint: Endpoint.Auth.registerAnonymous,
            method: .post
        )
        print("User ID: \(user.email)")
        return user
    }
    
    private static func loginAnonymousUser(user: User) async throws -> RefreshTokenResponse {
        let params: Parameters = ["email": user.email]
        
        let response: RefreshTokenResponse = try await NetworkManager.shared.request(
            endpoint: Endpoint.Auth.loginAnonymous,
            method: .post,
            parameters: params
        )
        
        AuthManager.shared.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        UserManager.shared.setUser(user)
        return response
    }
    
    static func registerAndLoginAnonymousUser() async -> Bool {
        do {
            if let user = UserManager.shared.getUser() {
                do {
                    _ = try await loginAnonymousUser(user: user)
                    return true
                } catch {
                    return try await performRegisterAndLogin()
                }
            } else {
                return try await performRegisterAndLogin()
            }
        } catch {
            return false
        }
    }
    
    private static func performRegisterAndLogin() async throws -> Bool {
        let anonymousUser = try await registerAnonymousUser()
        
        
        _ = try await loginAnonymousUser(user: anonymousUser)
        return true
    }
    
    static func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refresh = AuthManager.shared.getRefreshToken() else {
            completion(false)
            return
        }

        let params: Parameters = ["refreshToken": refresh]
        
        let url = NetworkConstants.baseURL + Endpoint.Auth.refreshToken.path
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-client-key": Constants.clientKey
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
        .validate()
        .responseDecodable(of: RefreshTokenResponse.self) { response in
            switch response.result {
            case .success(let tokenResponse):
                print("Refreshed token successfully")
                AuthManager.shared.saveTokens(
                    accessToken: tokenResponse.accessToken,
                    refreshToken: tokenResponse.refreshToken
                )
                completion(true)
                
            case .failure(let error):
                print("Failed to refresh token: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
}

