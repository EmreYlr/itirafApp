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
        return await TokenRefreshActor.shared.refresh()
    }
    
    private static func registerAnonymousUser() async throws -> User {
        let user: User = try await NetworkManager.shared.request(
            endpoint: Endpoint.Auth.registerAnonymous,
            method: .post
        )
        print("User ID: \(user.email)")
        return user
    }
    
    fileprivate static func performNetworkRefresh() async -> Bool {
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
        
        ClarityManager.shared.setUserId(user.id ?? "anonymous_user")
        
        return response
    }
    
    static func registerAndLoginAnonymousUser() async -> Bool {
        return await TokenRefreshActor.shared.registerAndLoginAnonymous()
    }
    
    fileprivate static func performRegisterAndLoginInternal() async -> Bool {
        do {
            if let user = UserManager.shared.getUser() {
                do {
                    _ = try await loginAnonymousUser(user: user)
                    return true
                } catch {
                    return try await executeRegisterSequence()
                }
            } else {
                return try await executeRegisterSequence()
            }
        } catch {
            return false
        }
    }
    
    private static func executeRegisterSequence() async throws -> Bool {
        let anonymousUser = try await registerAnonymousUser()
        _ = try await loginAnonymousUser(user: anonymousUser)
        return true
    }
}

actor TokenRefreshActor {
    static let shared = TokenRefreshActor()
    
    private var currentRefreshTask: Task<Bool, Never>?
    private var currentAnonymousTask: Task<Bool, Never>?
    
    func refresh() async -> Bool {
        if let task = currentRefreshTask {
            return await task.value
        }
        print("🟡 Token süresi doldu (Hata Kodu: 1402). Yenileme işlemi başlatılıyor...")
        
        let task = Task {
            return await AuthService.performNetworkRefresh()
        }
        
        currentRefreshTask = task
        let result = await task.value
        currentRefreshTask = nil
        
        if result {
            print("✅ Token başarıyla yenilendi.")
        } else {
            print("❌ Token yenileme başarısız.")
        }
        
        return result
    }
    
    func registerAndLoginAnonymous() async -> Bool {
        if let task = currentAnonymousTask {
            print("⏳ Zaten devam eden bir anonim kayıt işlemi var, bitmesi bekleniyor...")
            return await task.value
        }
        
        let task = Task {
            return await AuthService.performRegisterAndLoginInternal()
        }
        
        currentAnonymousTask = task
        let result = await task.value
        currentAnonymousTask = nil
        
        return result
    }
}
