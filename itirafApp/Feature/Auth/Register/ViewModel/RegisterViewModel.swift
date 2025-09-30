//
//  RegisterViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//

protocol RegisterViewModelProtocol {
    var delegate: RegisterViewModelOutputProtocol? { get set }
    func registerUser(email: String, password: String, username: String)
}

protocol RegisterViewModelOutputProtocol: AnyObject {
    func didRegisterSuccessfully()
    func didFailToRegister(with error: Error)
}

final class RegisterViewModel {
    weak var delegate: RegisterViewModelOutputProtocol?
    private let registerService: RegisterServiceProtocol
    
    init(registerService: RegisterServiceProtocol = RegisterService()) {
        self.registerService = registerService
    }
    
    func registerUser(email: String, password: String, username: String) {
        registerService.registerUser(email: email, password: password, username: username) { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didRegisterSuccessfully()
            case .failure(let error):
                self?.delegate?.didFailToRegister(with: error)
            }
        }
    }
    
}

extension RegisterViewModel: RegisterViewModelProtocol { }
