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
    
    func request<T: Decodable>(endpoint: EndpointType, method: HTTPMethod, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, completion: @escaping (Result<T, Error>) -> Void) {
        if endpoint.requiresAuth, AuthManager.shared.getAccessToken() == nil {
            DispatchQueue.main.async { NotificationCenter.default.post(name: .loginRequired, object: nil)
            }
            return
        }
        let url = NetworkConstants.baseURL + endpoint.rawValue
        
        var headers: HTTPHeaders = [ "Content-Type": "application/json", "x-client-key": Constants.clientKey ]
        
        if let token = AuthManager.shared.getAccessToken() { headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseDecodable(of: T.self) { response in
            
            let statusCode = response.response?.statusCode ?? -1
            print("STATUS CODE:", statusCode)
            
            if T.self == EmptyResponse.self, (200...299).contains(statusCode) {
                completion(.success(EmptyResponse() as! T)); return
            }
            
            switch response.result {
            case .success(let decoded):
                completion(.success(decoded))
            case .failure(let error):
                if response.response?.statusCode == 401 { self.handleTokenExpiration(endpoint: endpoint, method: method, parameters: parameters, encoding: encoding, completion: completion)
                }
                else {
                    completion(.failure(error))
                }
            }
        }
    }

    private func handleTokenExpiration<T: Decodable>(endpoint: EndpointType, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, completion: @escaping (Result<T, Error>) -> Void) {
        AuthService.refreshToken { success in
            if success { self.request(endpoint: endpoint, method: method, parameters: parameters, encoding: encoding, completion: completion)
            }
            else {
                AuthManager.shared.clearTokens()
                DispatchQueue.main.async { NotificationCenter.default.post(name: .userDidLogout, object: nil)
                }
            }
        }
    }

}


extension NetworkManager: NetworkService { }
