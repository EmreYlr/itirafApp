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
    private static func registerAnonymousUser(completion: @escaping (Result<AnonymousUser, Error>) -> Void) {
        NetworkManager.shared.request(endpoint: Endpoint.Auth.registerAnonymous, method: .post,parameters: nil, encoding: JSONEncoding.default) { (result: Result<AnonymousUser, Error>) in
            switch result {
            case .success(let response):
                print("Anonymous registration successful. User ID: \(response.email)")
                completion(.success(response))
            case .failure(let error):
                print("Anonymous registration failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
    }
    //TODO: -Register and login istediği attığımda ve kullanıcı yoksa thread hatası var ona bak.
    private static func loginAnonymousUser(email: String, completion: @escaping (Result<RefreshTokenResponse, Error>) -> Void) {
        let params: Parameters = [
            "email": email
        ]
        
        NetworkManager.shared.request(endpoint: Endpoint.Auth.loginAnonymous, method: .post, parameters: params, encoding: JSONEncoding.default) { (result: Result<RefreshTokenResponse, Error>) in
            switch result {
            case .success(let response):
                AuthManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func registerAndLoginAnonymousUser(completion: @escaping (Bool) -> Void) {
        if let savedEmail = UserDefaults.standard.string(forKey: .anonymousLogin) {
            loginAnonymousUser(email: savedEmail) { loginResult in
                switch loginResult {
                case .success:
                    completion(true)
                case .failure:
                    self.performRegisterAndLogin(completion: completion)
                }
            }
        } else {
            performRegisterAndLogin(completion: completion)
        }
    }

    private static func performRegisterAndLogin(completion: @escaping (Bool) -> Void) {
        registerAnonymousUser { registerResult in
            switch registerResult {
            case .success(let anonymousUser):
                UserDefaults.standard.set(anonymousUser.email, forKey: .anonymousLogin)
                loginAnonymousUser(email: anonymousUser.email) { loginResult in
                    switch loginResult {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            case .failure:
                completion(false)
            }
        }
    }

    
    static func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refresh = AuthManager.shared.getRefreshToken() else {
            completion(false)
            return
        }

        let params: Parameters = ["refresh_token": refresh]

        NetworkManager.shared.request(endpoint: Endpoint.Auth.refreshToken, method: .post, parameters: params, encoding: JSONEncoding.default) { (result: Result<RefreshTokenResponse, Error>) in
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

