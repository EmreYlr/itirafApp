//
//  ForgotPasswordService.swift
//  itirafApp
//
//  Created by Emre on 19.11.2025.
//
import Alamofire

protocol ForgotPasswordServiceProtocol {
    func resetPassword(email: String) async throws
}

final class ForgotPasswordService: ForgotPasswordServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
    
    func resetPassword(email: String) async throws {
        let parameters: [String: Any] = [
            "email": email
        ]
        
        let _ : Empty = try await networkService.request(
            endpoint: Endpoint.Auth.forgotPassword,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
        )
    }
}
