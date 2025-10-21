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
    
    private init() {
        self.session = Session(interceptor: AppRequestInterceptor())
    }
    
    func request<T: Decodable>(
        endpoint: EndpointType,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) async throws -> T {
        try checkAuthenticationIfNeeded(for: endpoint)
        
        let url = NetworkConstants.baseURL + endpoint.path
        let response = await session.request(url, method: method, parameters: parameters, encoding: encoding)
            .serializingData()
            .response
        
        try validateResponse(response, for: endpoint, method: method)
        
        guard let data = response.data, !data.isEmpty else {
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
            throw APIError(code: -1, type: "Serialization Error", message: "Empty response received but expected data.")
        }
        
        return try decodeResponse(data)
    }

    
    private func checkAuthenticationIfNeeded(for endpoint: EndpointType) throws {
        guard endpoint.requiresAuth, UserManager.shared.getUserIsAnonymous() else { return }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .loginRequired, object: nil)
        }
        throw APIError(code: 401 ,type: "AuthError", message: "Authentication required")
    }
    
    private func validateResponse(
        _ response: DataResponse<Data, AFError>,
        for endpoint: EndpointType,
        method: HTTPMethod
    ) throws {
        let statusCode = response.response?.statusCode ?? -1
        print("📡 [\(method.rawValue)] \(endpoint.path) - Status: \(statusCode)")
        
        guard (200...299).contains(statusCode) else {
            if let data = response.data,
               let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw apiError
            }
            throw APIError(code: statusCode, type: "HTTP Error", message: "Request failed with status code \(statusCode)")
        }
    }

    private func decodeResponse<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw apiError
            }
            throw APIError(code: -2, type: "Decoding Error", message: error.localizedDescription)
        }
    }

    
    func request<T: Decodable>(endpoint: EndpointType, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping (Result<T, Error>) -> Void) {
        if endpoint.requiresAuth, UserManager.shared.getUserIsAnonymous() {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .loginRequired, object: nil)
            }
            return
        }
        
        let url = NetworkConstants.baseURL + endpoint.path
        
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-client-key": Constants.clientKey
        ]
        
        if let token = AuthManager.shared.getAccessToken() { headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseDecodable(of: T.self) { response in
            let statusCode = response.response?.statusCode ?? -1
            print("STATUS CODE:", statusCode)
            
            if T.self == EmptyResponse.self, (200...299).contains(statusCode) {
                completion(.success(EmptyResponse() as! T))
                return
            }
            switch response.result {
            case .success(let decoded):
                completion(.success(decoded))
                
            case .failure(let afError):
                if let data = response.data,
                   let apiError = try? JSONDecoder().decode(APIError.self, from: data),
                   statusCode == 401 && apiError.code == 3011 {
                    
                    self.handleTokenExpiration(endpoint: endpoint, method: method, parameters: parameters, encoding: encoding, completion: completion)
                    return
                }
                
                if let data = response.data, let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    completion(.failure(apiError))
                } else {
                    completion(.failure(afError))
                }
            }
        }
    }
    //TODO: -Access Token expire olduğunda aynı zamanda Refresh Token de expire olmuşsa bir hata oluşuyor.(Sonsuz döngü) Eğer refresh token revoke olmuşsa bu sefer de Thread Performance Checker uyarısı alınıyor. Bunu çöz.
    private func handleTokenExpiration<T: Decodable>(endpoint: EndpointType, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, completion: @escaping (Result<T, Error>) -> Void) {
        AuthService.refreshToken { success in
            if success {
                self.request(endpoint: endpoint, method: method, parameters: parameters, encoding: encoding, completion: completion)
            }
            else {
                AuthManager.shared.clearTokens()
                UserManager.shared.clear()
                completion(.failure(APIError(code: 3011, type: "Authentication", message: "Authentication required.")))
            }
        }
    }
    
    //    func request<T: Decodable>(
    //        endpoint: EndpointType,
    //        method: HTTPMethod,
    //        parameters: Parameters? = nil,
    //        encoding: ParameterEncoding = JSONEncoding.default
    //    ) async throws -> T {
    //        try await withCheckedThrowingContinuation { continuation in
    //            self.request(endpoint: endpoint, method: method, parameters: parameters, encoding: encoding) { (result: Result<T, Error>) in
    //                switch result {
    //                case .success(let decoded):
    //                    continuation.resume(returning: decoded)
    //                case .failure(let error):
    //                    continuation.resume(throwing: error)
    //                }
    //            }
    //        }
    //    }
    
}


extension NetworkManager: NetworkService { }
