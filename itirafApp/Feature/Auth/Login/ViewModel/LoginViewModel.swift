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
}

protocol LoginViewModelOutputProtocol: AnyObject {
    func didLoginSuccessfully()
    func didFailToLogin(with error: Error)
}

@MainActor
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
}
extension LoginViewModel: @preconcurrency LoginViewModelProtocol { }
