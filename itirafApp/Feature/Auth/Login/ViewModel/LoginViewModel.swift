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
}

protocol LoginViewModelOutputProtocol: AnyObject {
    func didLoginSuccessfully()
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
            delegate?.didFailToLogin(with: error)
        }
    }
    
    func loginAnonymously() async {
        let isSuccess = await AuthService.registerAndLoginAnonymousUser()
        if isSuccess {
            delegate?.didLoginSuccessfully()
        } else {
            let error = AppError.anonymousUserNotLoggedIn
            delegate?.didFailToLogin(with: error)
        }
    }
}
extension LoginViewModel: LoginViewModelProtocol { }
