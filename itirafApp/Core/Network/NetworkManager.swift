//
//  NetworkManager.swift
//  itirafApp
//
//  Created by Emre on 24.09.2025.
//

import Alamofire
import Foundation
import OpenTelemetryApi

final class NetworkManager {
    static let shared = NetworkManager()
    private let tracer: Tracer
    
    private init() {
        self.tracer = OpenTelemetryManager.shared.getTracer(instrumentationName: "NetworkManager")
    }
    
    //TODO: -interceptor ekle
    
    func request<T: Decodable>(endpoint: EndpointType, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping (Result<T, Error>) -> Void) {
        // Create span for this request
        let spanName = "\(method.rawValue) \(endpoint.path)"
        let span = tracer.spanBuilder(spanName: spanName).startSpan()
        
        // Add span attributes
        span.setAttribute(key: "http.method", value: method.rawValue)
        span.setAttribute(key: "http.url", value: endpoint.path)
        span.setAttribute(key: "http.target", value: endpoint.path)
        span.setAttribute(key: "net.peer.name", value: NetworkConstants.baseURL)
        span.setAttribute(key: "requires_auth", value: endpoint.requiresAuth)
        
        if endpoint.requiresAuth, UserManager.shared.getUserIsAnonymous() {
            span.setAttribute(key: "auth.status", value: "anonymous_user")
            span.addEvent(name: "login_required")
            span.end()
            
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
        
        if let token = AuthManager.shared.getAccessToken() { 
            headers.add(name: "Authorization", value: "Bearer \(token)")
            span.setAttribute(key: "auth.status", value: "authenticated")
        } else {
            span.setAttribute(key: "auth.status", value: "no_token")
        }
        
        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseDecodable(of: T.self) { response in
            let statusCode = response.response?.statusCode ?? -1
            print("STATUS CODE:", statusCode)
            
            // Add response status to span
            span.setAttribute(key: "http.status_code", value: statusCode)
            
            if let data = response.data {
                span.setAttribute(key: "http.response_content_length", value: data.count)
            }
            
            if T.self == EmptyResponse.self, (200...299).contains(statusCode) {
                span.status = .ok
                span.end()
                completion(.success(EmptyResponse() as! T))
                return
            }
            
            switch response.result {
            case .success(let decoded):
                span.status = .ok
                span.addEvent(name: "decode_success")
                span.end()
                completion(.success(decoded))
                
            case .failure(let afError):
                if let data = response.data,
                   let apiError = try? JSONDecoder().decode(APIError.self, from: data),
                   statusCode == 401 && apiError.code == 3011 {
                    
                    span.addEvent(name: "token_expired", attributes: ["error_code": AttributeValue.int(apiError.code)])
                    span.end()
                    
                    self.handleTokenExpiration(endpoint: endpoint, method: method, parameters: parameters, encoding: encoding, completion: completion)
                    return
                }

                // Record error in span
                span.status = .error(description: afError.localizedDescription)
                span.setAttribute(key: "error", value: true)
                
                if let data = response.data, let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    span.setAttribute(key: "error.type", value: apiError.type)
                    span.setAttribute(key: "error.code", value: apiError.code)
                    span.setAttribute(key: "error.message", value: apiError.message)
                    span.end()
                    completion(.failure(apiError))
                } else {
                    span.setAttribute(key: "error.message", value: afError.localizedDescription)
                    span.end()
                    completion(.failure(afError))
                }
            }
        }
    }
    //TODO: -Access Token expire olduğunda aynı zamanda Refresh Token de expire olmuşsa bir hata oluşuyor.(Sonsuz döngü) Eğer refresh token revoke olmuşsa bu sefer de Thread Performance Checker uyarısı alınıyor. Bunu çöz.
    private func handleTokenExpiration<T: Decodable>(endpoint: EndpointType, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, completion: @escaping (Result<T, Error>) -> Void) {
        let span = tracer.spanBuilder(spanName: "token_refresh").startSpan()
        
        AuthService.refreshToken { success in
            if success {
                span.status = .ok
                span.addEvent(name: "token_refreshed")
                span.end()
                self.request(endpoint: endpoint, method: method, parameters: parameters, encoding: encoding, completion: completion)
            }
            else {
                span.status = .error(description: "Token refresh failed")
                span.setAttribute(key: "error", value: true)
                span.end()
                
                AuthManager.shared.clearTokens()
                UserManager.shared.clear()
                completion(.failure(APIError(code: 3011, type: "Authentication", message: "Authentication required.")))
            }
        }
    }
    
    func request<T: Decodable>(
        endpoint: EndpointType,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) async throws -> T {
        let spanName = "\(method.rawValue) \(endpoint.path) (async)"
        let span = tracer.spanBuilder(spanName: spanName).startSpan()
        span.setAttribute(key: "async", value: true)
        
        do {
            let result: T = try await withCheckedThrowingContinuation { continuation in
                self.request(endpoint: endpoint, method: method, parameters: parameters, encoding: encoding) { (result: Result<T, Error>) in
                    switch result {
                    case .success(let decoded):
                        continuation.resume(returning: decoded)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            span.status = .ok
            span.end()
            return result
        } catch {
            span.status = .error(description: error.localizedDescription)
            span.setAttribute(key: "error", value: true)
            span.end()
            throw error
        }
    }

}


extension NetworkManager: NetworkService { }
