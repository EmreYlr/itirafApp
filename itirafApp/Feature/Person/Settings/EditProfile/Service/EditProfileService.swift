//
//  EditProfileService.swift
//  itirafApp
//
//  Created by Emre on 7.12.2025.
//

protocol EditProfileServiceProtocol {
    
}

final class EditProfileService: EditProfileServiceProtocol {
    let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkManager.shared) {
        self.networkService = networkService
    }
}
