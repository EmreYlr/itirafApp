//
//  NetworkManager.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire
import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: Session
    private let refreshTokenSession: Session
    
    private init() {
        self.session = Session(interceptor: AppRequestInterceptor())
        self.refreshTokenSession = Session()
    }
    
    func request<T: Decodable>(
        endpoint: EndpointType,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) async throws -> T {
        try checkAuthenticationIfNeeded(for: endpoint)
        
        let url = NetworkConstants.baseURL + endpoint.path
        
        let dataTask = session.request(url, method: method, parameters: parameters, encoding: encoding)
            .validate()
            .serializingDecodable(T.self, emptyResponseCodes: [200, 201, 204, 205])
        
        let response = await dataTask.response
        
        switch response.result {
        case .success(let value):
            print("✅ [\(method.rawValue)] \(endpoint.path) - Status: \(response.response?.statusCode ?? 0)")
            return value
            
        case .failure(let error):
            let statusCode = error.responseCode ?? -1
            print("❌ [\(method.rawValue)] \(endpoint.path) - Status: \(statusCode)")
            
            if let data = response.data,
               let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                print("   -> Sunucu Hatası: \(apiError.message)")
                throw apiError
            }
            print("   -> Ağ Hatası: \(error.localizedDescription)")
            throw error
        }
    }
    
    func requestRefreshToken() async throws -> RefreshTokenResponse {
        guard let refresh = AuthManager.shared.getRefreshToken() else {
            throw APIError(code: 401, type: "AuthError", message: "Refresh token not found")
        }
        
        let url = NetworkConstants.baseURL + Endpoint.Auth.refreshToken.path
        let params: Parameters = ["refreshToken": refresh]
        let headers: HTTPHeaders = ["x-client-key": Constants.clientKey]
        
        let dataTask = refreshTokenSession.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .validate()
        .serializingDecodable(RefreshTokenResponse.self)
            
        let response = await dataTask.response
        
        switch response.result {
        case .success(let value):
            print("✅ Token successfully refreshed")
            return value
            
        case .failure(let error):
            print("❌ Failed to refresh token: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func checkAuthenticationIfNeeded(for endpoint: EndpointType) throws {
        guard endpoint.requiresAuth, UserManager.shared.getUserIsAnonymous() else { return }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .loginRequired, object: nil)
        }
        throw APIError(code: 401 ,type: "AuthError", message: "Authentication required")
    }
    
}

extension NetworkManager: NetworkService { }
