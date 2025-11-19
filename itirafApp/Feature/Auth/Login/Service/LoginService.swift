//
//  LoginService.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire
import Foundation

protocol LoginServiceProtocol {
    func loginUser(email: String, password: String) async throws
    func loginWithApple(request: AppleLoginRequest) async throws
}

final class LoginService {
    private let networkService: NetworkService
    private let userService: UserServiceProtocol
    private let deviceService: DeviceServiceProtocol
    private let followManager: FollowManager
    
    init(networkService: NetworkService = NetworkManager.shared,
         userService: UserServiceProtocol = UserService(),
         deviceService: DeviceServiceProtocol = DeviceService(),
         followManager: FollowManager = FollowManager.shared) {
        self.networkService = networkService
        self.userService = userService
        self.deviceService = deviceService
        self.followManager = followManager
    }
    
    func loginUser(email: String, password: String) async throws {
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        
        let response: RefreshTokenResponse = try await networkService.request(
            endpoint: Endpoint.Auth.login,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default
        )
        
        try await handleSuccessfulLogin(response: response)
    }
    
    func loginWithApple(request: AppleLoginRequest) async throws {
        dump(request)
        
        //        let response: RefreshTokenResponse = try await networkService.request(
        //            endpoint: Endpoint.Auth.appleLogin,
        //            method: .post,
        //            parameters: request,
        //            encoding: JSONParameterEncoder.default
        //        )
        
        //        try await handleSuccessfulLogin(response: response)
    }
    
    private func handleSuccessfulLogin(response: RefreshTokenResponse) async throws {
        AuthManager.shared.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        let user = try await userService.fetchCurrentUser()
        
        CrashlyticsManager.shared.setUserID(user.id ?? "NoN")
        CrashlyticsManager.shared.isUserAnonymous(false)
        
        do {
            try await followManager.loadFollowedChannels()
        } catch {
            print("⚠️ Takip edilen kanallar çekilirken hata oluştu: \(error.localizedDescription)")
            CrashlyticsManager.shared.sentNonFatal(error)
        }
        
        if let deviceToken = UserDefaults.standard.string(forKey: .deviceToken) {
            do {
                try await deviceService.registerDeviceToken(deviceToken, notificationEnabled: true)
            } catch {
                print("⚠️ Cihaz token'ı güncellenirken hata oluştu: \(error.localizedDescription)")
                CrashlyticsManager.shared.sentNonFatal(error)
            }
        }
    }
}
extension LoginService: LoginServiceProtocol { }
