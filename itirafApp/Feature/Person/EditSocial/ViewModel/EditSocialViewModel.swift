//
//  EditSocialViewModel.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//

protocol EditSocialViewModelProtocol {
    var delegate: EditSocialViewModelDelegate? { get set }
    var socialLinks: [Link]? { get }
    var socialLink: Link? { get }
    func getAllSocialPlatforms() -> [SocialPlatform]
    func getUserSocialLinks() -> Link?
    func createSocialLink(username: String, platform: SocialPlatform) async
    func editSocialLink(newUsername: String) async
    func deleteSocialLink() async
}

protocol EditSocialViewModelDelegate: AnyObject {
    func didUpdateSocialLinks()
    func didFailSocialLinks(with error: Error)
}

final class EditSocialViewModel {
    weak var delegate: EditSocialViewModelDelegate?
    var socialLinks: [Link]? = []
    var socialLink: Link?
    private let editSocialService: EditSocialServiceProtocol
    
    init(editSocialService: EditSocialServiceProtocol = EditSocialService()) {
        self.editSocialService = editSocialService
    }
    
    init(socialLink: Link, editSocialService: EditSocialServiceProtocol = EditSocialService()) {
        self.socialLink = socialLink
        self.editSocialService = editSocialService
    }
    init(socialLinks: [Link], editSocialService: EditSocialServiceProtocol = EditSocialService()) {
        self.socialLinks = socialLinks
        self.editSocialService = editSocialService
    }
    
    func getAllSocialPlatforms() -> [SocialPlatform] {
        return SocialPlatform.allCases
    }
    
    func getUserSocialLinks() -> Link? {
        return socialLink
    }

    func createSocialLink(username: String, platform: SocialPlatform) async {
        do {
            try await editSocialService.addSocialLink(username: username, platform: platform)
            UserManager.shared.clearSocialLinks()
            delegate?.didUpdateSocialLinks()
        } catch {
            delegate?.didFailSocialLinks(with: error)
        }
    }

    func editSocialLink(newUsername: String) async {
        guard var currentLink = socialLink else { return }
        
        do {
            try await editSocialService.editSocialLink(newUsername: newUsername, socialLink: currentLink)

            currentLink.username = newUsername

            UserManager.shared.updateSocialLink(currentLink)
            
            self.socialLink = currentLink
            delegate?.didUpdateSocialLinks()
        } catch {
            delegate?.didFailSocialLinks(with: error)
        }
    }

    func deleteSocialLink() async {
        guard let linkToDelete = socialLink else { return }
        
        do {
            try await editSocialService.deleteSocialLink(socialLink: linkToDelete)

            UserManager.shared.removeSocialLink(linkToDelete)
            
            delegate?.didUpdateSocialLinks()
        } catch {
            delegate?.didFailSocialLinks(with: error)
        }
    }
}

 extension EditSocialViewModel: EditSocialViewModelProtocol { }
