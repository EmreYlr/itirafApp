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
    static func refreshToken() async -> Bool {
        do {
            let tokenResponse = try await NetworkManager.shared.requestRefreshToken()
            AuthManager.shared.saveTokens(
                accessToken: tokenResponse.accessToken,
                refreshToken: tokenResponse.refreshToken
            )
            return true
        } catch {
            print("Failed to refresh token: \(error.localizedDescription)")
            return false
        }
    }
    
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
        
        CrashlyticsManager.shared.setUserID(user.id ?? "anonymous_user")
        CrashlyticsManager.shared.isUserAnonymous(true)
        
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
}

