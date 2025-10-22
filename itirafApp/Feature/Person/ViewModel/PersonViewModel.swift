//
//  PersonViewModel.swift
//  itirafApp
//
//  Created by Emre on 3.10.2025.
//

protocol PersonViewModelProtocol {
    var delegate: PersonViewModelOutputProtocol? { get set }
    func logout() async
    func checkUserAnonymous() -> Bool
}

protocol PersonViewModelOutputProtocol: AnyObject {
    func didLogoutSuccessfully()
    func didFailToLogout(with error: Error)
}

@MainActor
final class PersonViewModel {
    weak var delegate: PersonViewModelOutputProtocol?
    private let personService: PersonServiceProtocol
    
    init(personService: PersonServiceProtocol = PersonService()) {
        self.personService = personService
    }
    func logout() async {
        do {
            try await personService.logout()
            delegate?.didLogoutSuccessfully()
        } catch {
            delegate?.didFailToLogout(with: error)
        }
    }
    
    func checkUserAnonymous() -> Bool {
        return UserManager.shared.getUserIsAnonymous()
    }
}

extension PersonViewModel: @preconcurrency PersonViewModelProtocol { }
