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
    func updateUserSocialLinksVisibility(id: String, isVisible: Bool) async throws
}

protocol PersonViewModelOutputProtocol: AnyObject {
    func didUpdateSocialLinks()
    func didUserAnonymous()
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
        guard !UserManager.shared.getUserIsAnonymous() else {
            delegate?.didUserAnonymous()
            return
        }
        
        if let socialLinks = UserManager.shared.getSocialLinks(), !socialLinks.isEmpty {
            let socialLinks = UserSocialLink(links: socialLinks)
            self.socialLinks = socialLinks
            delegate?.didUpdateSocialLinks()
            return
        }
        
        do {
            socialLinks = try await personService.getUserSocialLinks()
            UserManager.shared.saveSocialLinks(socialLinks?.links ?? [])
            delegate?.didUpdateSocialLinks()
        } catch {
            delegate?.didFailSocialLinks(with: error)
        }
    }
    
    func updateUserSocialLinksVisibility(id: String, isVisible: Bool) async throws {
        try await personService.updateSocialLinkVisibility(id: id, isVisible: isVisible)
        
        if let currentLinks = UserManager.shared.getSocialLinks(),
           let index = currentLinks.firstIndex(where: { $0.id == id }) {
            
            var updatedLink = currentLinks[index]
            updatedLink.visible = isVisible

            UserManager.shared.updateSocialLink(updatedLink)
        }
    }
}

extension PersonViewModel: @preconcurrency PersonViewModelProtocol { }
