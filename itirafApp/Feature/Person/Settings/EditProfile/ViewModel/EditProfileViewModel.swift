//
//  EditProfileViewModel.swift
//  itirafApp
//
//  Created by Emre on 7.12.2025.
//

protocol EditProfileViewModelProtocol {
    var delegate: EditProfileViewModelDelegate? { get set  }
    func getUserInfo() -> User?
    func deleteAccount() async
}

protocol EditProfileViewModelDelegate: AnyObject {
    func didDeleteProfile()
    func didFailWithError(_ error: Error)
}

final class EditProfileViewModel {
    weak var delegate: EditProfileViewModelDelegate?
    let service: EditProfileServiceProtocol
    
    init(service: EditProfileServiceProtocol = EditProfileService()) {
        self.service = service
    }
    
    func getUserInfo() -> User? {
        return UserManager.shared.getUser()
    }
    
    func deleteAccount() async {
        do {
            try await service.deleteAccount()
            self.delegate?.didDeleteProfile()
        } catch {
            self.delegate?.didFailWithError(error)
        }
    }
}

extension EditProfileViewModel: EditProfileViewModelProtocol { }
