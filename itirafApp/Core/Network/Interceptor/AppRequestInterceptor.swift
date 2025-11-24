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
        
        guard let dataRequest = request as? DataRequest else {
            return completion(.doNotRetry)
        }
        
        guard let data = dataRequest.data else {
            return completion(.doNotRetry)
        }
        
        guard let apiError = try? JSONDecoder().decode(APIError.self, from: data) else {
            return completion(.doNotRetry)
        }
        
        if apiError.code == 1401 {
            guard AuthManager.shared.getAccessToken() != nil else {
                return completion(.doNotRetry)
            }
            print("🔴 Geçersiz token (Hata Kodu: 1401). Oturum sonlandırılıyor...")
            AuthManager.shared.clearTokens()
            UserManager.shared.clear()
            Task {
                await MainActor.run {
                    NotificationCenter.default.post(name: .loginRequired, object: nil)
                }
            }
            
            return completion(.doNotRetry)
        }

        guard apiError.code == 1402 else {
            return completion(.doNotRetry)
        }
        
        print("🟡 Token süresi doldu (Hata Kodu: 1402). Yenileme veya anonim oturum işlemi başlatılıyor...")
        
        Task {
            if await AuthService.refreshToken() {
                print("✅ Token başarıyla yenilendi. Asıl istek yeniden denenecek.")
                completion(.retry)
            } else {
                AuthManager.shared.clearTokens()
                UserManager.shared.clear()
                
                if await AuthService.registerAndLoginAnonymousUser() {
                    print("✅ Anonim kullanıcı başarıyla oluşturuldu ve giriş yapıldı. Asıl istek yeniden denenecek.")
                    completion(.retry)
                } else {
                    print("❌ Anonim kullanıcı oluşturulamadı. Oturum sonlandırılacak.")
                    await MainActor.run {
                        NotificationCenter.default.post(name: .loginRequired, object: nil)
                    }
                    completion(.doNotRetry)
                }
            }
        }
    }
}
