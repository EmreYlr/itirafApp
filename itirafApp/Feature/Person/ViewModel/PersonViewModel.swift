//
//  PersonViewModel.swift
//  itirafApp
//
//  Created by Emre on 3.10.2025.
//

protocol PersonViewModelProtocol {
    var delegate: PersonViewModelOutputProtocol? { get set }
    var socialLinks: UserSocialLink? { get }
    func getUserSocialLinks() async
}

protocol PersonViewModelOutputProtocol: AnyObject {
    func didUpdateSocialLinks()
    func didFailSocialLinks(with error: Error)
}

@MainActor
final class PersonViewModel {
    weak var delegate: PersonViewModelOutputProtocol?
    private let personService: PersonServiceProtocol
    var socialLinks: UserSocialLink?
    
    init(personService: PersonServiceProtocol = PersonService()) {
        self.personService = personService
    }
    
    func getUserSocialLinks() async {
        do {
            socialLinks = try await personService.getUserSocialLinks()
            delegate?.didUpdateSocialLinks()
        } catch {
            delegate?.didFailSocialLinks(with: error)
        }
    }
}

extension PersonViewModel: @preconcurrency PersonViewModelProtocol { }
