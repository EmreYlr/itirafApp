//
//  ForgotPasswordViewModel.swift
//  itirafApp
//
//  Created by Emre on 19.11.2025.
//

protocol ForgotPasswordViewModelProtocol {
    var delegate: ForgotPasswordViewModelDelegate? { get set }
    func resetPassword(email: String) async
}

protocol ForgotPasswordViewModelDelegate: AnyObject {
    func didResetPasswordSuccessfully()
    func didFailToResetPassword(with error: Error)
}

final class ForgotPasswordViewModel {
    weak var delegate: ForgotPasswordViewModelDelegate?
    let service: ForgotPasswordServiceProtocol
    
    init(service: ForgotPasswordServiceProtocol = ForgotPasswordService()) {
        self.service = service
    }
    
    func resetPassword(email: String) async {
        do {
            try await service.resetPassword(email: email)
            delegate?.didResetPasswordSuccessfully()
        } catch {
            delegate?.didFailToResetPassword(with: error)
        }
    }
}

extension ForgotPasswordViewModel: ForgotPasswordViewModelProtocol { }
