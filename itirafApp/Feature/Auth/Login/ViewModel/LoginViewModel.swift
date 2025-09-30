//
//  LoginViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//

protocol LoginViewModelProtocol {
    var delegate: LoginViewModelOutputProtocol? { get set }
    func loginUser(email: String, password: String)
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
    
    func loginUser(email: String, password: String) {
        loginService.loginUser(email: email, password: password) {[weak self] result in
            switch result {
            case .success:
                self?.delegate?.didLoginSuccessfully()
            case .failure(let error):
                self?.delegate?.didFailToLogin(with: error)
            }
        }
    }
    
}

extension LoginViewModel: LoginViewModelProtocol { }
