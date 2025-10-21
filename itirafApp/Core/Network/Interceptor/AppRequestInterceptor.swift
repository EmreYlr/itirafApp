//
//  AppRequestInterceptor.swift
//  itirafApp
//
//  Created by Emre on 21.10.2025.
//
import Alamofire
import Foundation

final class AppRequestInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        
        adaptedRequest.setValue(Constants.clientKey, forHTTPHeaderField: "x-client-key")
        
        if let token = AuthManager.shared.getAccessToken() {
            adaptedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(adaptedRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.response, response.statusCode == 401 else {
            return completion(.doNotRetry)
        }

        if let url = request.request?.url?.absoluteString, url.contains(Endpoint.Auth.refreshToken.path) {
            return completion(.doNotRetry)
        }
        
        print("Token süresi doldu. Yenileme işlemi başlatılıyor...")

        AuthService.refreshToken { success in
            if success {
                print("Token başarıyla yenilendi. Asıl istek yeniden denenecek.")
                completion(.retry)
            } else {
                print("Token yenilenemedi. Kullanıcı oturumu sonlandırılacak.")
                AuthManager.shared.clearTokens()
                UserManager.shared.clear()
                NotificationCenter.default.post(name: .loginRequired, object: nil)
                completion(.doNotRetry)
            }
        }
    }
}
