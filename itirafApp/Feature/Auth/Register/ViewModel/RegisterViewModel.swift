//
//  RegisterViewModel.swift
//  itirafApp
//
//  Created by Emre on 16.09.2025.
//

protocol RegisterViewModelProtocol {
    var delegate: RegisterViewModelOutputProtocol? { get set }
    func registerUser(email: String, password: String) async
    func resendVerificationEmail(to: String) async
    func getPrivacyURL() -> String
    func getTermsURL() -> String
}

protocol RegisterViewModelOutputProtocol: AnyObject {
    func didRegisterSuccessfully()
    func didRequireEmailVerification(for: String)
    func didFailToRegister(with error: Error)
}

final class RegisterViewModel {
    weak var delegate: RegisterViewModelOutputProtocol?
    private let registerService: RegisterServiceProtocol
    
    init(registerService: RegisterServiceProtocol = RegisterService()) {
        self.registerService = registerService
    }
    
    func registerUser(email: String, password: String) async {
        do {
            try await registerService.registerUser(email: email, password: password)
            delegate?.didRegisterSuccessfully()
        } catch {
            if let apiError = error as? APIError, apiError.code == 1405 {
                delegate?.didRequireEmailVerification(for: email)
            } else {
                delegate?.didFailToRegister(with: error)
            }
        }
    }
    
    func resendVerificationEmail(to: String) async {
        do {
            try await registerService.resendVerificationEmail(to: to)
        } catch {
            delegate?.didFailToRegister(with: error)
        }
    }
    
    func getPrivacyURL() -> String {
        return Constants.privacy
    }
    
    func getTermsURL() -> String {
        return Constants.terms
    }
}

extension RegisterViewModel: RegisterViewModelProtocol { }
