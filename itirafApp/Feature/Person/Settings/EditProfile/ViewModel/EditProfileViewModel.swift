//
//  EditProfileViewModel.swift
//  itirafApp
//
//  Created by Emre on 7.12.2025.
//

protocol EditProfileViewModelProtocol {
    var delegate: EditProfileViewModelDelegate? { get set  }
}

protocol EditProfileViewModelDelegate: AnyObject {
    func didUpdateProfile()
    func didFailWithError(_ error: Error)
}

final class EditProfileViewModel {
    weak var delegate: EditProfileViewModelDelegate?
    let service: EditProfileServiceProtocol
    
    init(service: EditProfileServiceProtocol = EditProfileService()) {
        self.service = service
    }
    
}

extension EditProfileViewModel: EditProfileViewModelProtocol { }
