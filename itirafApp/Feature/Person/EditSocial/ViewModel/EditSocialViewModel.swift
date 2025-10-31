//
//  EditSocialViewModel.swift
//  itirafApp
//
//  Created by Emre on 31.10.2025.
//

protocol EditSocialViewModelProtocol {
    var delegate: EditSocialViewModelDelegate? { get set }
    var socialLink: Link? { get }
    func getAllSocialPlatforms() -> [SocialPlatform]
    func getUserSocialLinks() -> Link?
    func createSocialLink(username: String, platform: SocialPlatform) async
    func editSocialLink(newUsername: String) async
    func deleteSocialLink() async
}

protocol EditSocialViewModelDelegate: AnyObject {
    func didUpdateSocialLinks()
    func didCreateSocialLinks()
    func didDeleteSocialLinks()
    func didFailSocialLinks(with error: Error)
}

final class EditSocialViewModel {
    weak var delegate: EditSocialViewModelDelegate?
    var socialLink: Link?
    private let editSocialService: EditSocialServiceProtocol
    
    init(editSocialService: EditSocialServiceProtocol = EditSocialService()) {
        self.editSocialService = editSocialService
    }
    
    init(socialLink: Link, editSocialService: EditSocialServiceProtocol = EditSocialService()) {
        self.socialLink = socialLink
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
            delegate?.didCreateSocialLinks()
        } catch {
            delegate?.didFailSocialLinks(with: error)
        }
    }
    
    func editSocialLink(newUsername: String) async {
        guard let socialLink = socialLink else {
            return
        }
        do {
            try await editSocialService.editSocialLink(newUsername: newUsername, socialLink: socialLink)
            delegate?.didUpdateSocialLinks()
        } catch {
            delegate?.didFailSocialLinks(with: error)
        }
    }
    
    func deleteSocialLink() async {
        guard let socialLink = socialLink else {
            return
        }
        do {
            try await editSocialService.deleteSocialLink(socialLink: socialLink)
            delegate?.didDeleteSocialLinks()
        } catch {
            delegate?.didFailSocialLinks(with: error)
        }
    }
}

 extension EditSocialViewModel: EditSocialViewModelProtocol { }
