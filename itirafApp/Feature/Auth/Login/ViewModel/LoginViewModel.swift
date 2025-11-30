//
//  LoginViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//
import Foundation

protocol LoginViewModelProtocol {
    var delegate: LoginViewModelOutputProtocol? { get set }
    func loginUser(email: String, password: String) async
    func loginAnonymously() async
    func loginWithApple(request: AppleLoginRequest) async
    func loginWithGoogle(request: GoogleLoginRequest) async
    func resendVerificationEmail(to: String) async
}

protocol LoginViewModelOutputProtocol: AnyObject {
    func didLoginSuccessfully()
    func didRequireEmailVerification(for email: String)
    func didFailToLogin(with error: Error)
}

final class LoginViewModel {
    weak var delegate: LoginViewModelOutputProtocol?
    private let loginService: LoginServiceProtocol
    
    init(loginService: LoginServiceProtocol = LoginService()) {
        self.loginService = loginService
    }

    func loginUser(email: String, password: String) async {
        do {
            try await loginService.loginUser(email: email, password: password)
            delegate?.didLoginSuccessfully()
        } catch {
            if let apiError = error as? APIError, apiError.code == 1405 {
                delegate?.didRequireEmailVerification(for: email)
            } else {
                delegate?.didFailToLogin(with: error)
            }
        }
    }
    
    func loginWithApple(request: AppleLoginRequest) async {
        do {
            try await loginService.loginWithApple(request: request)
            delegate?.didLoginSuccessfully()
        } catch {
            delegate?.didFailToLogin(with: error)
        }
    }
    
    func loginWithGoogle(request: GoogleLoginRequest) async {
        do {
            try await loginService.loginWithGoogle(request: request)
            delegate?.didLoginSuccessfully()
        } catch {
            delegate?.didFailToLogin(with: error)
        }
    }
    
    func loginAnonymously() async {
        let isSuccess = await AuthService.registerAndLoginAnonymousUser()
        if isSuccess {
            delegate?.didLoginSuccessfully()
        } else {
            let error = AuthError.anonymousUserNotLoggedIn
            delegate?.didFailToLogin(with: error)
        }
    }
    
    func resendVerificationEmail(to: String) async {
        do {
            try await loginService.resendVerificationEmail(to: to)
        } catch {
            delegate?.didFailToLogin(with: error)
        }
    }
}
extension LoginViewModel: LoginViewModelProtocol { }
