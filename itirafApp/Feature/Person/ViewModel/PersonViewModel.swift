//
//  PersonViewModel.swift
//  itirafApp
//
//  Created by Emre on 3.10.2025.
//


protocol PersonViewModelProtocol {
    var delegate: PersonViewModelOutputProtocol? { get set }
    func logout()
    func checkUserAnonymous() -> Bool
}

protocol PersonViewModelOutputProtocol: AnyObject {
    func didLogoutSuccessfully()
    func didFailToLogout(with error: Error)
}

final class PersonViewModel {
    weak var delegate: PersonViewModelOutputProtocol?
    private let personService: PersonServiceProtocol
    
    init(personService: PersonServiceProtocol = PersonService()) {
        self.personService = personService
    }
    
    func logout() {
        personService.logout { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didLogoutSuccessfully()
            case .failure(let error):
                self?.delegate?.didFailToLogout(with: error)
            }
        }
    }
    
    func checkUserAnonymous() -> Bool {
        return UserManager.shared.getUserIsAnonymous()
    }
    
}

extension PersonViewModel: PersonViewModelProtocol { }
