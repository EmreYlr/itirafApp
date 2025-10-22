//
//  RegisterViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//

protocol RegisterViewModelProtocol {
    var delegate: RegisterViewModelOutputProtocol? { get set }
    func registerUser(email: String, password: String, username: String) async
}

protocol RegisterViewModelOutputProtocol: AnyObject {
    func didRegisterSuccessfully()
    func didFailToRegister(with error: Error)
}

@MainActor
final class RegisterViewModel {
    weak var delegate: RegisterViewModelOutputProtocol?
    private let registerService: RegisterServiceProtocol
    
    init(registerService: RegisterServiceProtocol = RegisterService()) {
        self.registerService = registerService
    }
    
    func registerUser(email: String, password: String, username: String) async {
        do {
            try await registerService.registerUser(email: email, password: password, username: username)
            delegate?.didRegisterSuccessfully()
        } catch {
            delegate?.didFailToRegister(with: error)
        }
    }
}

extension RegisterViewModel: @preconcurrency RegisterViewModelProtocol { }
