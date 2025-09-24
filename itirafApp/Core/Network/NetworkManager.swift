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
    private init() {}
    
    func request<T: Decodable>( path: String, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping (Result<T, Error>) -> Void) {
        let url = NetworkConstants.baseURL + path
        
        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        if let token = AuthManager.shared.getAccessToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
        .validate()
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let decoded):
                completion(.success(decoded))
            case .failure(let error):
                if response.response?.statusCode == 401 {
                    self.handleTokenExpiration(path: path, method: method, parameters: parameters, encoding: encoding, completion: completion)
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func handleTokenExpiration<T: Decodable>( path: String, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, completion: @escaping (Result<T, Error>) -> Void) {
        AuthService.refreshToken { success in
            if success {
                self.request(path: path, method: method, parameters: parameters, encoding: encoding, completion: completion)
            } else {
                AuthManager.shared.clearTokens()
                DispatchQueue.main.async { NotificationCenter.default.post(name: .userDidLogout, object: nil)
                }
            }
        }
    }
}

extension NetworkManager: NetworkService { }
